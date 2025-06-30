PROCEDURE P_CARGAR_VENTAS_AL_DW(
    p_fecha_inicio IN DATE,
    p_fecha_fin    IN DATE
) AS
    v_filas_insertadas NUMBER := 0;
BEGIN
    -- Eliminar datos del rango antes de insertar, para evitar duplicados.
    DELETE FROM Hecho_Ventas
    WHERE fecha_id BETWEEN TO_NUMBER(TO_CHAR(p_fecha_inicio, 'YYYYMMDD'))
                       AND TO_NUMBER(TO_CHAR(p_fecha_fin, 'YYYYMMDD'));

    -- Insertar datos desde el sistema transaccional al DWH.
    INSERT INTO Hecho_Ventas (
        fecha_id, producto_id, usuario_id, tienda_id,
        cantidad, precio_unitario, total_venta
    )
    SELECT
        TO_NUMBER(TO_CHAR(p.fecha_pedido, 'YYYYMMDD')),
        dp.producto_id,
        p.usuario_id,
        prod.tienda_id,
        dp.cantidad,
        dp.precio_unitario,
        dp.cantidad * dp.precio_unitario
    FROM pedidos p
    JOIN detalles_pedido dp
        ON p.pedido_id = dp.pedido_id
       AND TRUNC(p.fecha_pedido) = TRUNC(dp.fecha_pedido_fk)
    JOIN productos prod
        ON dp.producto_id = prod.producto_id
    WHERE p.fecha_pedido BETWEEN p_fecha_inicio AND p_fecha_fin
      AND p.estado IN ('PAGADO', 'ENTREGADO', 'ENVIADO');

    v_filas_insertadas := SQL%ROWCOUNT;

    IF v_filas_insertadas = 0 THEN
        DBMS_OUTPUT.PUT_LINE(' No se insertaron ventas en el rango especificado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE(' Ventas insertadas correctamente: ' || v_filas_insertadas);
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en P_CARGAR_VENTAS_AL_DW: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END;
