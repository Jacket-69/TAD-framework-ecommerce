/*Triggers de Validacion funcional*/

-- 1. creacion de trigger para validar stock, en caso de que un pedido se pase del stock que tengamos le dira directamente "Stock insuficiente"
CREATE OR REPLACE TRIGGER trg_validar_stock
BEFORE INSERT ON detalles_pedido
FOR EACH ROW
DECLARE
    v_stock productos.stock%TYPE;
BEGIN
    SELECT stock INTO v_stock
    FROM productos
    WHERE producto_id = :NEW.producto_id;

    IF :NEW.cantidad > v_stock THEN
        RAISE_APPLICATION_ERROR(-20001, 'Stock insuficiente');
    END IF;
END;
/

-- 2. este Trigger valida que las fechas de los pedidos funcionen correctamente y no posean fechas futuras al presente, este se activa cuando se inserta un pedido en la tabla pedidos
CREATE OR REPLACE TRIGGER trg_validar_fecha_pedido
BEFORE INSERT OR UPDATE ON pedidos
FOR EACH ROW
BEGIN
    IF :NEW.fecha_pedido > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20002, 'La fecha del pedido no puede ser futura');
    END IF;
END;
/

-- 3. Trigger para advertir sobre la falta de fondos, algo basico para hacerle saber al cliente que no se haga el weon y pague el precio correspondiente, se activa antes de registrar un pago
CREATE OR REPLACE TRIGGER trg_validar_monto_pago
BEFORE INSERT ON pagos
FOR EACH ROW
DECLARE
    v_total_pedido pedidos.total%TYPE;
BEGIN
    SELECT total INTO v_total_pedido
    FROM pedidos
    WHERE pedido_id = :NEW.pedido_id;

    IF :NEW.monto < v_total_pedido THEN
        RAISE_APPLICATION_ERROR(-20003, 'El monto del pago no puede ser menor al total del pedido');
    END IF;
END;
/

-- 4. Validar que el estado del pedido sea uno permitido, en caso de que no lo sea, el trigger se dispara y lanza un error
CREATE OR REPLACE TRIGGER trg_validar_estado_pedido
BEFORE INSERT OR UPDATE ON pedidos
FOR EACH ROW
BEGIN
    IF LOWER(:NEW.estado) NOT IN ('pendiente', 'enviado', 'cancelado', 'completado') THEN
        RAISE_APPLICATION_ERROR(-20004, 'Estado de pedido no válido. Valores permitidos: pendiente, enviado, cancelado, completado.');
    END IF;
END;
/


-- 5. (peticion de gerencia) Disminuir stock al registrar una venta
CREATE OR REPLACE TRIGGER trg_disminuir_stock_venta
AFTER INSERT ON detalles_pedido
FOR EACH ROW
BEGIN
    UPDATE productos
    SET stock = stock - :NEW.cantidad
    WHERE producto_id = :NEW.producto_id;
END;
/

-- 6. Asegurarse que el trigger anterior no deje el stock negativo después de la venta
CREATE OR REPLACE TRIGGER trg_no_negativo
AFTER UPDATE OF stock ON productos
FOR EACH ROW
WHEN (NEW.stock < 0)
BEGIN
    RAISE_APPLICATION_ERROR(-20010, 'Error: Stock no puede quedar en negativo.');
END;
/

-- Trigger del datawarehouse: tabla productos
CREATE OR REPLACE TRIGGER trg_productos_audit
AFTER INSERT OR UPDATE OR DELETE ON productos
FOR EACH ROW
DECLARE
    v_old_values CLOB;
    v_new_values CLOB;
    v_usuario_app VARCHAR2(100) := SYS_CONTEXT('USERENV', 'SESSION_USER');
BEGIN
    IF INSERTING THEN
        v_new_values := 'producto_id: ' || :NEW.producto_id ||
                        ' | tienda_id: ' || :NEW.tienda_id ||
                        ' | nombre: ' || :NEW.nombre ||
                        ' | descripcion: ' || :NEW.descripcion ||
                        ' | precio: ' || :NEW.precio ||
                        ' | stock: ' || :NEW.stock ||
                        ' | sku: ' || :NEW.sku;
        INSERT INTO tabla_auditoria (nombre_tabla, tipo_operacion, registro_id, valores_nuevos, usuario_accion, fecha_accion)
        VALUES ('productos', 'INSERT', :NEW.producto_id, v_new_values, v_usuario_app, SYSDATE);

    ELSIF UPDATING THEN
        v_old_values := 'producto_id: ' || :OLD.producto_id ||
                        ' | tienda_id: ' || :OLD.tienda_id ||
                        ' | nombre: ' || :OLD.nombre ||
                        ' | descripcion: ' || :OLD.descripcion ||
                        ' | precio: ' || :OLD.precio ||
                        ' | stock: ' || :OLD.stock ||
                        ' | sku: ' || :OLD.sku;
        v_new_values := 'producto_id: ' || :NEW.producto_id ||
                        ' | tienda_id: ' || :NEW.tienda_id ||
                        ' | nombre: ' || :NEW.nombre ||
                        ' | descripcion: ' || :NEW.descripcion ||
                        ' | precio: ' || :NEW.precio ||
                        ' | stock: ' || :NEW.stock ||
                        ' | sku: ' || :NEW.sku;
        INSERT INTO tabla_auditoria (nombre_tabla, tipo_operacion, registro_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion)
        VALUES ('productos', 'UPDATE', :NEW.producto_id, v_old_values, v_new_values, v_usuario_app, SYSDATE);

    ELSIF DELETING THEN
        v_old_values := 'producto_id: ' || :OLD.producto_id ||
                        ' | tienda_id: ' || :OLD.tienda_id ||
                        ' | nombre: ' || :OLD.nombre ||
                        ' | descripcion: ' || :OLD.descripcion ||
                        ' | precio: ' || :OLD.precio ||
                        ' | stock: ' || :OLD.stock ||
                        ' | sku: ' || :OLD.sku;
        INSERT INTO tabla_auditoria (nombre_tabla, tipo_operacion, registro_id, valores_antiguos, usuario_accion, fecha_accion)
        VALUES ('productos', 'DELETE', :OLD.producto_id, v_old_values, v_usuario_app, SYSDATE);
    END IF;
END;
/

/*
SELECT * FROM tabla_auditoria WHERE nombre_tabla = 'productos';
-- Insert de ejemplo
INSERT INTO productos (producto_id, tienda_id, nombre, descripcion, precio, stock, sku)
VALUES (101, 1, 'Audífonos', 'Audífonos con cancelación de ruido', 199.99, 30, 'AUDIO123');

-- Update de ejemplo
UPDATE productos
SET precio = 179.99, stock = 28
WHERE producto_id = 101;

-- Delete de ejemplo
DELETE FROM productos
WHERE producto_id = 101;

*/
