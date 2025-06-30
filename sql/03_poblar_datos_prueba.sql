-- --------------------------------------------------------------------------
/*
Este script inserta un par de cositas en cada tabla
para que no te sientas tan solo al hacer tus primeras consultas.
Ejecútalo como el usuario ECOMMERCE_FRAMEWORK.
*/
-- --------------------------------------------------------------------------

SET SERVEROUTPUT ON;

-- Limpiamos por si ejecutas esto más de una vez.
BEGIN
    DELETE FROM pagos;
    DELETE FROM detalles_pedido;
    DELETE FROM pedidos;
    DELETE FROM producto_categorias;
    DELETE FROM productos;
    DELETE FROM categorias;
    DELETE FROM usuario_roles;
    DELETE FROM direcciones;
    DELETE FROM usuarios;
    DELETE FROM roles;
    DELETE FROM tiendas;
    DBMS_OUTPUT.PUT_LINE('✔️  Tablas limpias');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Error al limpiar: ' || SQLERRM);
END;
/

-- Insertar datos
DECLARE
    -- Tiendas
    v_tienda1_id NUMBER;
    v_tienda2_id NUMBER;

    -- Roles
    v_rol_admin_id NUMBER;
    v_rol_cliente_id NUMBER;
    v_rol_analista_id NUMBER;

    -- Usuarios
    v_usuario_admin_id NUMBER;
    v_usuario_cliente_id NUMBER;
    v_usuario_analista1_id NUMBER;
    v_usuario_analista2_id NUMBER;

    -- Categorías y Productos
    v_categoria1_id NUMBER;
    v_categoria2_id NUMBER;
    v_producto1_id NUMBER;
    v_producto2_id NUMBER;

    -- Fecha de pedido
    v_fecha_pedido DATE := TO_DATE('24-06-2025', 'DD-MM-YYYY');
BEGIN
    -- Tienda 1
    INSERT INTO tiendas (nombre, url_dominio)
    VALUES ('La Zapatillería Feroz', 'zapatillasferoces.com')
    RETURNING tienda_id INTO v_tienda1_id;

    -- Tienda 2
    INSERT INTO tiendas (nombre, url_dominio)
    VALUES ('Botines Eternos', 'botineseternos.com')
    RETURNING tienda_id INTO v_tienda2_id;

    -- Roles
    INSERT INTO roles (nombre_rol)
    VALUES ('Jefe de Jefes')
    RETURNING rol_id INTO v_rol_admin_id;

    INSERT INTO roles (nombre_rol)
    VALUES ('Cliente Fiel')
    RETURNING rol_id INTO v_rol_cliente_id;

    INSERT INTO roles (nombre_rol)
    VALUES ('Analista')
    RETURNING rol_id INTO v_rol_analista_id;

    -- Usuarios para Tienda 1
    INSERT INTO usuarios (tienda_id, email, password_hash, nombre, apellido)
    VALUES (v_tienda1_id, 'admin@tienda1.com', 'hash_del_jefe', 'El', 'Admin')
    RETURNING usuario_id INTO v_usuario_admin_id;

    INSERT INTO usuarios (tienda_id, email, password_hash, nombre, apellido)
    VALUES (v_tienda1_id, 'benja.lopez@cliente.com', 'hash_del_cliente', 'Benja', 'López')
    RETURNING usuario_id INTO v_usuario_cliente_id;

    INSERT INTO usuarios (tienda_id, email, password_hash, nombre, apellido)
    VALUES (v_tienda1_id, 'ana@zapatillas.com', 'hash_analista1', 'Ana', 'Lista')
    RETURNING usuario_id INTO v_usuario_analista1_id;

    -- Usuario analista para Tienda 2
    INSERT INTO usuarios (tienda_id, email, password_hash, nombre, apellido)
    VALUES (v_tienda2_id, 'luis@botines.com', 'hash_analista2', 'Luis', 'Datos')
    RETURNING usuario_id INTO v_usuario_analista2_id;

    -- Roles asignados
    INSERT INTO usuario_roles (usuario_id, rol_id) VALUES (v_usuario_admin_id, v_rol_admin_id);
    INSERT INTO usuario_roles (usuario_id, rol_id) VALUES (v_usuario_cliente_id, v_rol_cliente_id);
    INSERT INTO usuario_roles (usuario_id, rol_id) VALUES (v_usuario_analista1_id, v_rol_analista_id);
    INSERT INTO usuario_roles (usuario_id, rol_id) VALUES (v_usuario_analista2_id, v_rol_analista_id);

    -- Categorías (solo para tienda 1)
    INSERT INTO categorias (tienda_id, nombre)
    VALUES (v_tienda1_id, 'Para Correr con Estilo')
    RETURNING categoria_id INTO v_categoria1_id;

    INSERT INTO categorias (tienda_id, nombre)
    VALUES (v_tienda1_id, 'Para Pisar Hormigas')
    RETURNING categoria_id INTO v_categoria2_id;

    -- Productos (solo para tienda 1)
    INSERT INTO productos (tienda_id, nombre, precio, stock, sku)
    VALUES (v_tienda1_id, 'Zapatillas "El Rayo"', 69990, 20, 'ZAP-RAYO-2025')
    RETURNING producto_id INTO v_producto1_id;

    INSERT INTO productos (tienda_id, nombre, precio, stock, sku)
    VALUES (v_tienda1_id, 'Zapatos "El Gerente"', 42000, 50, 'ZAP-GERENTE-2025')
    RETURNING producto_id INTO v_producto2_id;

    -- Producto Categorías
    INSERT INTO producto_categorias (producto_id, categoria_id)
    VALUES (v_producto1_id, v_categoria1_id);

    INSERT INTO producto_categorias (producto_id, categoria_id)
    VALUES (v_producto2_id, v_categoria2_id);

    -- Pedido de prueba (cliente de tienda 1)
    INSERT INTO pedidos (usuario_id, fecha_pedido, estado, total)
    VALUES (v_usuario_cliente_id, v_fecha_pedido, 'PAGADO', 69990);

    INSERT INTO detalles_pedido (pedido_id, fecha_pedido_fk, producto_id, cantidad, precio_unitario)
    VALUES (1, v_fecha_pedido, v_producto1_id, 1, 69990);

    INSERT INTO pagos (pedido_id, fecha_pedido_fk, monto, fecha_pago, metodo_pago, estado_pago)
    VALUES (1, v_fecha_pedido, 69990, v_fecha_pedido, 'TARJETA_DE_CRÉDITO_DE_JUGUETE', 'COMPLETADO');

    DBMS_OUTPUT.PUT_LINE('✔️  Datos insertados con éxito.');
END;
/

COMMIT;
PROMPT --- ¡Listo Calisto! ---
