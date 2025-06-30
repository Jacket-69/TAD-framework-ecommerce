-- Pruebas funcionales PARTE 2
-- CREAR TIENDA PARA LAS PRUEBAS
INSERT INTO tiendas (nombre, url_dominio)
VALUES ('Tienda de Juan', 'tienda-juan.cl');

-- Esto es orientativo BTW

-- Prueba: CREAR USUARIO
INSERT INTO usuarios (tienda_id, email, password_hash, nombre, apellido)
VALUES (1, 'juan.juan@juan.cl', 'hash123', 'Juan', 'Juan');

-- Prueba: INSERTAR DIRECCIÓN
INSERT INTO direcciones (usuario_id, calle, ciudad, region, codigo_postal, pais)
VALUES (
    (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl'),
    'Av. Central 123', 'Santiago', 'Metropolitana', '8320000', 'Chile'
);

-- Prueba: CREAR ROL Y ASIGNAR A USUARIO
INSERT INTO roles (nombre_rol) VALUES ('cliente');

INSERT INTO usuario_roles (usuario_id, rol_id)
VALUES (
    (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl'),
    (SELECT rol_id FROM roles WHERE nombre_rol = 'cliente')
);

-- Prueba: INSERTAR PRODUCTO
INSERT INTO productos (tienda_id, nombre, descripcion, precio, stock, sku)
VALUES (1, 'Mouse Inalámbrico', 'Mouse gamer sin cable', 15000, 20, 'SKU-MOU-001');

-- Prueba: CREAR PEDIDO
INSERT INTO pedidos (usuario_id, direccion_envio_id, estado, total)
VALUES (
    (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl'),
    (SELECT direccion_id FROM direcciones WHERE calle = 'Av. Central 123'),
    'PENDIENTE', 30000
);

-- Prueba: REGISTRAR PAGO (validado contra total del pedido)
INSERT INTO pagos (pedido_id, fecha_pedido_fk, monto, metodo_pago, estado_pago)
VALUES (
    (SELECT pedido_id FROM pedidos WHERE usuario_id = (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl')),
    (SELECT fecha_pedido FROM pedidos WHERE usuario_id = (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl')),
    30000, 'tarjeta', 'COMPLETADO'
);

-- Prueba: UPDATE DE PEDIDO
UPDATE pedidos
SET estado = 'ENVIADO'
WHERE pedido_id = (
    SELECT pedido_id FROM pedidos WHERE usuario_id = (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl')
);

-- Prueba: UPDATE DE PAGO
UPDATE pagos
SET metodo_pago = 'transferencia'
WHERE pedido_id = (
    SELECT pedido_id FROM pedidos WHERE usuario_id = (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl')
);

-- Prueba: UPDATE DIRECCIÓN
UPDATE direcciones
SET calle = 'Nueva calle 456'
WHERE usuario_id = (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl');

-- Prueba: ERROR PEDIDO CON FECHA FUTURA
BEGIN
    INSERT INTO pedidos (usuario_id, direccion_envio_id, fecha_pedido, estado, total)
    VALUES (
        (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl'),
        (SELECT direccion_id FROM direcciones WHERE usuario_id = (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl')),
        SYSDATE + 10, 'PENDIENTE', 5000
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM); -- Esperado: -20002
END;
/

-- Prueba: ERROR STOCK INSUFICIENTE
BEGIN
    INSERT INTO detalles_pedido (pedido_id, fecha_pedido_fk, producto_id, cantidad, precio_unitario)
    VALUES (
        (SELECT pedido_id FROM pedidos WHERE usuario_id = (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl')),
        (SELECT fecha_pedido FROM pedidos WHERE usuario_id = (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl')),
        (SELECT producto_id FROM productos WHERE sku = 'SKU-MOU-001'),
        1000, 15000
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM); -- Esperado: -20001
END;
/

-- Prueba: ERROR MONTO INSUFICIENTE EN PAGO
BEGIN
    INSERT INTO pagos (pedido_id, fecha_pedido_fk, monto, metodo_pago, estado_pago)
    VALUES (
        (SELECT pedido_id FROM pedidos WHERE usuario_id = (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl')),
        (SELECT fecha_pedido FROM pedidos WHERE usuario_id = (SELECT usuario_id FROM usuarios WHERE email = 'juan.juan@juan.cl')),
        10000, 'tarjeta', 'COMPLETADO'
    );
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM); -- Esperado: -20003
END;
/


/*
-- segun "internet" esto es obligatorio para que lo siguiente funcione
BEGIN
  DBMS_SESSION.SET_IDENTIFIER('juan.juan@juan.cl');
END;
-- no olvidar
*/


-- 1. SELECT sobre productos
SELECT * FROM v_productos;

-- 2. INSERT de un nuevo producto
INSERT INTO v_productos (nombre, descripcion, precio, stock, sku)
VALUES ('Teclado Mecánico', 'Teclado retroiluminado RGB', 35000, 15, 'SKU-TEC-001');

-- 3. UPDATE en producto insertado (solo dentro de su tienda)
UPDATE v_productos
SET precio = 32990
WHERE sku = 'SKU-TEC-001';

-- 4. INSERT de un pedido de un usuario de su tienda
INSERT INTO v_pedidos (usuario_id, direccion_envio_id, estado, total)
VALUES (
    (SELECT usuario_id FROM v_usuarios WHERE email = 'juan.juan@juan.cl'),
    (SELECT direccion_id FROM v_direcciones WHERE usuario_id = (SELECT usuario_id FROM v_usuarios WHERE email = 'juan.juan@juan.cl')),
    'PENDIENTE', 20000
);

-- 5. INSERT en detalles del pedido (usar el pedido mas reciente del usuario pls)
INSERT INTO v_detalles_pedido (pedido_id, fecha_pedido_fk, producto_id, cantidad, precio_unitario)
VALUES (
    (SELECT pedido_id FROM v_pedidos WHERE usuario_id = (SELECT usuario_id FROM v_usuarios WHERE email = 'juan.juan@juan.cl') ORDER BY pedido_id DESC FETCH FIRST 1 ROWS ONLY),
    (SELECT fecha_pedido FROM v_pedidos WHERE usuario_id = (SELECT usuario_id FROM v_usuarios WHERE email = 'juan.juan@juan.cl') ORDER BY pedido_id DESC FETCH FIRST 1 ROWS ONLY),
    (SELECT producto_id FROM v_productos WHERE sku = 'SKU-TEC-001'),
    2, 17500
);

-- 6. UPDATE del stock del producto
UPDATE v_productos
SET stock = stock - 2
WHERE sku = 'SKU-TEC-001';

/*PRUEBAS QUE DEBERÍAN FALLAR (por falta de permisos)*/
-- Estas líneas deberían dar error si se ejecutan como vendedor_user:

-- 7. DELETE en productos
DELETE FROM v_productos WHERE sku = 'SKU-TEC-001';

-- 8. INSERT en usuarios (prohibido)
INSERT INTO v_usuarios (tienda_id, email, password_hash, nombre, apellido)
VALUES (1, 'falso@usuario.cl', 'x', 'Falso', 'Usuario');

-- 9. INSERT en pagos (prohibido)
INSERT INTO v_pagos (pedido_id, fecha_pedido_fk, monto, metodo_pago, estado_pago)
VALUES (999, SYSDATE, 20000, 'tarjeta', 'COMPLETADO');
