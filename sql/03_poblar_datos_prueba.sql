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
INSERT INTO tiendas (tienda_id, nombre, url_dominio) VALUES (1, 'La Zapatillería Feroz', 'zapatillasferoces.com');
INSERT INTO roles (rol_id, nombre_rol) VALUES (1, 'Jefe de Jefes');
INSERT INTO roles (rol_id, nombre_rol) VALUES (2, 'Cliente Fiel');
INSERT INTO usuarios (usuario_id, tienda_id, email, password_hash, nombre, apellido) VALUES (101, 1, 'admin@tienda.com', 'hash_del_jefe', 'El', 'Admin');
INSERT INTO usuarios (usuario_id, tienda_id, email, password_hash, nombre, apellido) VALUES (102, 1, 'benja.lopez@cliente.com', 'hash_del_cliente', 'Benja', 'López');
INSERT INTO usuario_roles (usuario_id, rol_id) VALUES (101, 1);
INSERT INTO usuario_roles (usuario_id, rol_id) VALUES (102, 2);
INSERT INTO categorias (categoria_id, tienda_id, nombre) VALUES (1, 1, 'Para Correr con Estilo');
INSERT INTO categorias (categoria_id, tienda_id, nombre) VALUES (2, 1, 'Para Pisar Hormigas');

INSERT INTO productos (producto_id, tienda_id, nombre, precio, stock, sku) VALUES (1, 1, 'Zapatillas "El Rayo"', 69990, 20, 'ZAP-RAYO-2025');
INSERT INTO productos (producto_id, tienda_id, nombre, precio, stock, sku) VALUES (2, 1, 'Zapatos "El Gerente"', 42000, 50, 'ZAP-GERENTE-2025');

INSERT INTO producto_categorias (producto_id, categoria_id) VALUES (1, 1);
INSERT INTO producto_categorias (producto_id, categoria_id) VALUES (2, 2);

-- Un pedido de prueba
DECLARE
    v_fecha_pedido DATE := TO_DATE('24-06-2025', 'DD-MM-YYYY');
BEGIN
    INSERT INTO pedidos (pedido_id, usuario_id, fecha_pedido, estado, total)
    VALUES (1, 102, v_fecha_pedido, 'PAGADO', 69990);

    INSERT INTO detalles_pedido (pedido_id, fecha_pedido_fk, producto_id, cantidad, precio_unitario)
    VALUES (1, v_fecha_pedido, 1, 1, 69990);

    INSERT INTO pagos (pedido_id, fecha_pedido_fk, monto, fecha_pago, metodo_pago, estado_pago)
    VALUES (1, v_fecha_pedido, 69990, v_fecha_pedido, 'TARJETA_DE_CRÉDITO_DE_JUGUETE', 'COMPLETADO');
    DBMS_OUTPUT.PUT_LINE('✔️  Pedido de prueba insertado con éxito.');
END;
/

COMMIT;
PROMPT --- ¡Listo Calisto! ---
