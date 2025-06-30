-- Pruebas funcionales 3, me rendi
-- ===============================================
-- 📦 SCRIPT COMPLETO DE PRUEBAS FUNCIONALES ACTUALIZADO
-- Basado en estructuras dinámicas y seguras
-- ===============================================

SET SERVEROUTPUT ON;

DECLARE
    v_tienda_id     NUMBER;
    v_usuario_id    NUMBER;
    v_direccion_id  NUMBER;
    v_producto_id   NUMBER;
    v_pedido_id     NUMBER;
    v_rol_id        NUMBER;
    v_fecha_pedido  DATE := SYSDATE;

    v_email         VARCHAR2(100);
    v_nombre_user   VARCHAR2(50);
    v_apellido_user VARCHAR2(50) := 'Prueba';
    v_calle         VARCHAR2(100);
    v_sku           VARCHAR2(50);
    v_nombre_prod   VARCHAR2(100);
BEGIN
    -- Crear tienda si no existe
    BEGIN
        SELECT tienda_id INTO v_tienda_id
        FROM tiendas
        WHERE nombre = 'Tienda Full Prueba';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO tiendas (nombre, url_dominio)
            VALUES ('Tienda Full Prueba', 'fullprueba.cl')
            RETURNING tienda_id INTO v_tienda_id;
    END;

    -- Crear usuario
    v_email := 'user_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '@mail.cl';
    v_nombre_user := 'Juan_' || TO_CHAR(SYSDATE, 'MI:SS');

    INSERT INTO usuarios (tienda_id, email, password_hash, nombre, apellido)
    VALUES (v_tienda_id, v_email, 'hash123', v_nombre_user, v_apellido_user)
    RETURNING usuario_id INTO v_usuario_id;

    -- Crear direccion
    v_calle := 'Av. Test ' || TO_CHAR(SYSDATE, 'MI:SS');
    INSERT INTO direcciones (usuario_id, calle, ciudad, region, codigo_postal, pais)
    VALUES (v_usuario_id, v_calle, 'Santiago', 'RM', '1234567', 'Chile')
    RETURNING direccion_id INTO v_direccion_id;

    -- Crear o buscar rol "cliente"
    BEGIN
        SELECT rol_id INTO v_rol_id FROM roles WHERE nombre_rol = 'cliente';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO roles (nombre_rol) VALUES ('cliente')
            RETURNING rol_id INTO v_rol_id;
    END;
    INSERT INTO usuario_roles (usuario_id, rol_id) VALUES (v_usuario_id, v_rol_id);

    -- Crear producto
    v_sku := 'SKU-' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS');
    v_nombre_prod := 'Producto Prueba ' || TO_CHAR(SYSDATE, 'MI:SS');
    INSERT INTO productos (tienda_id, nombre, descripcion, precio, stock, sku)
    VALUES (v_tienda_id, v_nombre_prod, 'Producto de prueba completo.', 19990, 20, v_sku)
    RETURNING producto_id INTO v_producto_id;

    -- Crear pedido
    INSERT INTO pedidos (usuario_id, direccion_envio_id, fecha_pedido, estado, total)
    VALUES (v_usuario_id, v_direccion_id, v_fecha_pedido, 'PENDIENTE', 19990)
    RETURNING pedido_id INTO v_pedido_id;

    -- Insertar detalle
    INSERT INTO detalles_pedido (pedido_id, fecha_pedido_fk, producto_id, cantidad, precio_unitario)
    VALUES (v_pedido_id, v_fecha_pedido, v_producto_id, 1, 19990);

    -- Insertar pago
    INSERT INTO pagos (pedido_id, fecha_pedido_fk, monto, fecha_pago, metodo_pago, estado_pago)
    VALUES (v_pedido_id, v_fecha_pedido, 19990, v_fecha_pedido, 'tarjeta', 'COMPLETADO');

    -- Errores esperados
    BEGIN
        INSERT INTO pedidos (usuario_id, direccion_envio_id, fecha_pedido, estado, total)
        VALUES (v_usuario_id, v_direccion_id, SYSDATE + 10, 'PENDIENTE', 5000);
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('🛑 ERROR esperado (fecha futura): ' || SQLERRM);
    END;

    BEGIN
        INSERT INTO detalles_pedido (pedido_id, fecha_pedido_fk, producto_id, cantidad, precio_unitario)
        VALUES (v_pedido_id, v_fecha_pedido, v_producto_id, 1000, 19990);
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('🛑 ERROR esperado (stock insuficiente): ' || SQLERRM);
    END;

    BEGIN
        INSERT INTO pagos (pedido_id, fecha_pedido_fk, monto, fecha_pago, metodo_pago, estado_pago)
        VALUES (v_pedido_id, v_fecha_pedido, 10000, v_fecha_pedido, 'tarjeta', 'COMPLETADO');
    EXCEPTION
        WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('🛑 ERROR esperado (monto insuficiente): ' || SQLERRM);
    END;

    -- Confirmaciones
    DBMS_OUTPUT.PUT_LINE('✅ Usuario creado: ' || v_email);
    DBMS_OUTPUT.PUT_LINE('📦 Producto: ' || v_nombre_prod || ' (SKU: ' || v_sku || ')');
    DBMS_OUTPUT.PUT_LINE('🧾 Pedido ID: ' || v_pedido_id);
    DBMS_OUTPUT.PUT_LINE('💳 Pago procesado.');
END;
/

-- ===============================================
-- 📊 PRUEBAS PARA VENDEDOR_USER (con SET_IDENTIFIER)
-- ===============================================
BEGIN
  DBMS_SESSION.SET_IDENTIFIER('user_' || TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') || '@mail.cl');
END;
/

-- Vista de productos
SELECT * FROM v_productos;

-- Insert de producto válido
INSERT INTO v_productos (nombre, descripcion, precio, stock, sku)
VALUES ('Teclado Mecánico ' || TO_CHAR(SYSDATE, 'HH24MISS'), 'RGB test', 35000, 15, 'SKU-TEC-' || TO_CHAR(SYSDATE, 'HH24MISS'));

-- Update de producto (mismo SKU)
UPDATE v_productos
SET precio = 32990
WHERE sku = 'SKU-TEC-' || TO_CHAR(SYSDATE, 'HH24MISS');

-- Insert de pedido
INSERT INTO v_pedidos (usuario_id, direccion_envio_id, estado, total)
VALUES (
    (SELECT usuario_id FROM v_usuarios WHERE ROWNUM = 1),
    (SELECT direccion_id FROM v_direcciones WHERE ROWNUM = 1),
    'PENDIENTE', 20000
);

-- Insert de detalle de pedido
INSERT INTO v_detalles_pedido (pedido_id, fecha_pedido_fk, producto_id, cantidad, precio_unitario)
VALUES (
    (SELECT pedido_id FROM v_pedidos ORDER BY pedido_id DESC FETCH FIRST 1 ROWS ONLY),
    (SELECT fecha_pedido FROM v_pedidos ORDER BY pedido_id DESC FETCH FIRST 1 ROWS ONLY),
    (SELECT producto_id FROM v_productos WHERE ROWNUM = 1),
    2, 17500
);

-- Update de stock
UPDATE v_productos
SET stock = stock - 2
WHERE ROWNUM = 1;

-- PRUEBAS QUE DEBEN FALLAR (según permisos)
-- Estas generarán errores si se ejecutan por vendedor_user

-- DELETE en productos
DELETE FROM v_productos WHERE ROWNUM = 1;

-- INSERT en usuarios (prohibido)
INSERT INTO v_usuarios (tienda_id, email, password_hash, nombre, apellido)
VALUES (1, 'falso@usuario.cl', 'x', 'Falso', 'Usuario');

-- INSERT en pagos (prohibido)
INSERT INTO v_pagos (pedido_id, fecha_pedido_fk, monto, metodo_pago, estado_pago)
VALUES (999, SYSDATE, 20000, 'tarjeta', 'COMPLETADO');
