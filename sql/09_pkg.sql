-- ===================================================================
-- SCRIPT FINAL: Paquete de Inteligencia de Negocio (PKG_INTELIGENCIA_NEGOCIO)
-- NOMBRE:             Francisco Rojo Alfaro
-- ===================================================================

SET SERVEROUTPUT ON;

-- ===================================================================
-- PACKAGE
-- ===================================================================


CREATE OR REPLACE PACKAGE PKG_INTELIGENCIA_NEGOCIO AS

    -- Excepción personalizada para cuando no hay datos suficientes para un cálculo.
    e_datos_insuficientes EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_datos_insuficientes, -20301);

    -- Tipos de datos para devolver listas de resultados complejos (ranking de clientes).
    TYPE t_cliente_valioso IS RECORD (
        nombre_cliente  VARCHAR2(101),
        gasto_total     NUMBER,
        total_pedidos   NUMBER
    );
    TYPE t_lista_clientes IS TABLE OF t_cliente_valioso;

    -- === FUNCIONES ANALÍTICAS PARA EL ANALISTA ===

    /**
     * Identifica y devuelve una lista con el TOP N de clientes más valiosos
     * basado en el total gastado en un período.
     */
    FUNCTION F_OBTENER_CLIENTES_VALIOSOS(
        p_top_n        IN NUMBER,
        p_fecha_inicio IN DATE,
        p_fecha_fin    IN DATE
    ) RETURN t_lista_clientes;
    
    /**
     * Calcula el Valor Promedio de Orden (AOV) para un período.
     */
    FUNCTION F_CALCULAR_AOV_PERIODO(
        p_fecha_inicio IN DATE,
        p_fecha_fin    IN DATE
    ) RETURN NUMBER;

    -- === PROCEDIMIENTOS ADMINISTRATIVOS DE SOPORTE ===
    
    /**
     * Proceso ETL para cargar las ventas del sistema transaccional al DWH.
     */
    PROCEDURE P_CARGAR_VENTAS_AL_DW(
        p_fecha_inicio IN DATE,
        p_fecha_fin    IN DATE
    );

    /**
     * Sincroniza las tablas de dimensiones con los datos maestros.
     */
    PROCEDURE P_SINCRONIZAR_DIMENSIONES;

END PKG_INTELIGENCIA_NEGOCIO;
/



-- ===================================================================
-- PACKAGE BODY
-- ===================================================================

CREATE OR REPLACE PACKAGE BODY PKG_INTELIGENCIA_NEGOCIO AS

    FUNCTION F_OBTENER_CLIENTES_VALIOSOS(
        p_top_n        IN NUMBER,
        p_fecha_inicio IN DATE,
        p_fecha_fin    IN DATE
    ) RETURN t_lista_clientes AS
        v_lista_top_clientes t_lista_clientes;
    BEGIN
        -- La consulta se hace sobre las VISTAS para respetar la seguridad de la tienda.
        SELECT
            du.nombre || ' ' || du.apellido,
            SUM(hv.total_venta),
            COUNT(DISTINCT hv.id_venta)
        BULK COLLECT INTO v_lista_top_clientes
        FROM v_hecho_ventas hv
        JOIN v_dim_usuario du ON hv.usuario_id = du.usuario_id
        JOIN v_dim_tiempo dt ON hv.fecha_id = dt.fecha_id
        WHERE dt.fecha BETWEEN p_fecha_inicio AND p_fecha_fin
        GROUP BY du.usuario_id, du.nombre, du.apellido
        ORDER BY SUM(hv.total_venta) DESC
        FETCH FIRST p_top_n ROWS ONLY;

        IF v_lista_top_clientes.COUNT = 0 THEN
            RAISE e_datos_insuficientes;
        END IF;

        RETURN v_lista_top_clientes;
    EXCEPTION
        WHEN e_datos_insuficientes THEN
            DBMS_OUTPUT.PUT_LINE('  No se encontraron clientes con ventas en el período especificado.');
            RETURN NULL;
    END F_OBTENER_CLIENTES_VALIOSOS;

    FUNCTION F_CALCULAR_AOV_PERIODO(
        p_fecha_inicio IN DATE,
        p_fecha_fin    IN DATE
    ) RETURN NUMBER AS
        v_total_ventas  NUMBER;
        v_total_ordenes NUMBER;
    BEGIN
        SELECT NVL(SUM(total_venta), 0), NVL(COUNT(DISTINCT id_venta), 0)
        INTO v_total_ventas, v_total_ordenes
        FROM v_hecho_ventas hv
        JOIN v_dim_tiempo dt ON hv.fecha_id = dt.fecha_id
        WHERE dt.fecha BETWEEN p_fecha_inicio AND p_fecha_fin;

        IF v_total_ordenes = 0 THEN
            RETURN 0;
        END IF;

        RETURN v_total_ventas / v_total_ordenes;
    END F_CALCULAR_AOV_PERIODO;

    PROCEDURE P_CARGAR_VENTAS_AL_DW( p_fecha_inicio IN DATE, p_fecha_fin IN DATE) AS
    BEGIN
        INSERT INTO Hecho_Ventas (fecha_id, producto_id, usuario_id, tienda_id, cantidad, precio_unitario, total_venta)
        SELECT TO_NUMBER(TO_CHAR(p.fecha_pedido, 'YYYYMMDD')), dp.producto_id, p.usuario_id, prod.tienda_id, dp.cantidad, dp.precio_unitario, (dp.cantidad * dp.precio_unitario)
        FROM pedidos p
        JOIN detalles_pedido dp ON p.pedido_id = dp.pedido_id AND p.fecha_pedido = dp.fecha_pedido_fk
        JOIN productos prod ON dp.producto_id = prod.producto_id
        WHERE p.fecha_pedido BETWEEN p_fecha_inicio AND p_fecha_fin AND p.estado IN ('PAGADO', 'ENTREGADO', 'ENVIADO');
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(' Proceso ETL de ventas completado. Filas insertadas: ' || SQL%ROWCOUNT);
    EXCEPTION
        WHEN OTHERS THEN ROLLBACK; RAISE;
    END P_CARGAR_VENTAS_AL_DW;

    PROCEDURE P_SINCRONIZAR_DIMENSIONES AS
    BEGIN
        MERGE INTO Dim_Producto d USING productos s ON (d.producto_id = s.producto_id)
        WHEN MATCHED THEN UPDATE SET d.nombre = s.nombre, d.descripcion = s.descripcion, d.precio = s.precio, d.sku = s.sku
        WHEN NOT MATCHED THEN INSERT (producto_id, nombre, descripcion, precio, sku) VALUES (s.producto_id, s.nombre, s.descripcion, s.precio, s.sku);

        MERGE INTO Dim_Usuario d USING usuarios s ON (d.usuario_id = s.usuario_id)
        WHEN MATCHED THEN UPDATE SET d.nombre = s.nombre, d.apellido = s.apellido, d.email = s.email, d.tienda_id = s.tienda_id
        WHEN NOT MATCHED THEN INSERT (usuario_id, nombre, apellido, email, tienda_id) VALUES (s.usuario_id, s.nombre, s.apellido, s.email, s.tienda_id);
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE(' Dimensiones sincronizadas.');
    END P_SINCRONIZAR_DIMENSIONES;

END PKG_INTELIGENCIA_NEGOCIO;
/
