/*funciones parte 2, ahora tengo fe*/
-- funcion que devuelve un resumen de las ventas de un usuario (total pedidos, total ventas, promedio por pedido)
CREATE OR REPLACE FUNCTION resumen_ventas_usuario(p_usuario_id IN NUMBER)
RETURN VARCHAR2 IS
    v_total_ventas   NUMBER := 0;
    v_cantidad_pedidos NUMBER := 0;
    v_promedio       NUMBER := 0;
    v_resumen        VARCHAR2(500);
BEGIN
    -- Contar cantidad de pedidos del usuario
    SELECT COUNT(*)
    INTO v_cantidad_pedidos
    FROM pedidos
    WHERE usuario_id = p_usuario_id;

    -- Sumar total de ventas de esos pedidos
    SELECT SUM(total)
    INTO v_total_ventas
    FROM pedidos
    WHERE usuario_id = p_usuario_id;

    -- Calcular promedio por pedido
    IF v_cantidad_pedidos > 0 THEN
        v_promedio := v_total_ventas / v_cantidad_pedidos;
    END IF;

    -- resumen
    v_resumen := 'Usuario ' || p_usuario_id || ' ha realizado ' || v_cantidad_pedidos || 
                 ' pedido(s) con un total de $' || TO_CHAR(v_total_ventas, '999,999.99') ||
                 ' y un promedio de $' || TO_CHAR(v_promedio, '999,999.99');

    RETURN v_resumen;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Usuario sin pedidos.';
    WHEN OTHERS THEN
        RETURN 'Error al calcular resumen de ventas.';
END;
/

-- probar con:
-- SELECT resumen_ventas_usuario(1) FROM dual;


-- funcion que verifica compras en los ultimos 30 dias (1 = si, 0 = no, -1 = no existe el user xd)
CREATE OR REPLACE FUNCTION verificar_usuario_activo_en_compras(p_usuario_id IN NUMBER)
RETURN INT IS
    v_existe         INT;
    v_reciente_compra INT;
BEGIN
    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO v_existe
    FROM usuarios
    WHERE usuario_id = p_usuario_id;

    IF v_existe = 0 THEN
        RETURN -1; -- Usuario no existe
    END IF;

    -- Verificar si tiene pedidos
    SELECT COUNT(*) INTO v_reciente_compra
    FROM pedidos
    WHERE usuario_id = p_usuario_id
      AND fecha_pedido >= SYSDATE - 30;

    IF v_reciente_compra > 0 THEN
        RETURN 1; -- Usuario activo
    ELSE
        RETURN 0; -- Usuario inactivo
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN -1; -- En caso de error
END;
/


-- probar con:
-- SELECT verificar_usuario_activo_en_compras(1) FROM dual;


-- funcion que retorna la cantidad de productos de una tienda con stock bajo o negativo
CREATE OR REPLACE FUNCTION productos_bajo_stock(p_tienda_id IN NUMBER,p_minimo_stock IN NUMBER) RETURN NUMBER IS
    v_cantidad NUMBER := 0;
BEGIN
    SELECT COUNT(*)
    INTO v_cantidad
    FROM productos
    WHERE tienda_id = p_tienda_id
      AND stock < p_minimo_stock;

    RETURN v_cantidad;

EXCEPTION
    WHEN OTHERS THEN
        RETURN -1; -- Código de error genérico
END;
/

-- Contar productos con stock menor a 10 en tienda 1
-- SELECT productos_bajo_stock(1, 10) FROM dual;


-- funcion que calcula el total de ventas realizadas en una region especifica
-- (no pregunten que es el upper, lo saque de stackglow)
CREATE OR REPLACE FUNCTION ventas_por_region(p_region IN VARCHAR2)
RETURN NUMBER IS
    v_total NUMBER := 0;
BEGIN
    SELECT SUM(p.total)
    INTO v_total
    FROM pedidos p
    JOIN direcciones d ON p.direccion_envio_id = d.direccion_id
    WHERE UPPER(d.region) = UPPER(p_region);

    RETURN NVL(v_total, 0);

EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END;
/

-- Total de ventas enviadas a la región 'Metropolitana'
-- SELECT ventas_por_region('Metropolitana') FROM dual;
