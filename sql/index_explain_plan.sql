--Indices priorizados en tabla_auditoria
CREATE INDEX idx_auditoria_tabla ON tabla_auditoria(nombre_tabla);

--Indice para filtrar tabla auditada.
CREATE INDEX idx_auditoria_tipo_operacion ON tabla_auditoria(tipo_operacion);

--Indice para filtrar tipo de accion(INSERT,UPDATE,DELETE).
CREATE INDEX idx_auditoria_usuario_fecha ON tabla_auditoria(usuario_accion, fecha_accion);

--Indice para trazabilidad por usuario o temporalidad de actividad.
CREATE INDEX idx_auditoria_fecha ON tabla_auditoria(fecha_accion);

--Indice para reportes temporales o especificas.
CREATE INDEX idx_auditoria_registro ON tabla_auditoria(registro_id);

--Indice para localizar cambio de fila afectada.
CREATE INDEX idx_auditoria_valores_antiguos ON tabla_auditoria(valores_antiguos) INDEXTYPE IS CTXSYS.CONTEXT;

--Indice de apoyo en tablas claves
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_fecha_registro ON usuarios(fecha_registro);

--Indice para nuevos usuarios por fecha y precio.
CREATE INDEX idx_productos_nombre ON productos(nombre);
CREATE INDEX idx_productos_precio ON productos(precio);

--Indice para cambios de precios.
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha_pedido);

--Indice para seguimiento de pedidos en rango de fechas.
CREATE INDEX idx_pedidos_usuario_estado ON pedidos(usuario_id, estado);

--Indice de reportes por cliente y estado del pedido.
CREATE INDEX idx_pagos_metodo_estado ON pagos(metodo_pago, estado_pago);

--Indice de pagos y deteccion de fallas.
CREATE INDEX idx_detalles_pedido_producto ON detalles_pedido(producto_id);

--Indice productos mas vendidos o devoluciones.
CREATE INDEX idx_direcciones_ciudad ON direcciones(ciudad);




--Explain Plan, se crearan 3 explain plan con las siguientes especificaciones(Resumen total de ventas,Pedidos de un usuario especifico, Resumen total de operaciones).
--Primer Explain plan(Resumen total de Operaciones.)

EXPLAIN PLAN FOR
SELECT nombre_tabla, tipo_operacion, COUNT(*) AS total_operaciones
FROM tabla_auditoria
GROUP BY nombre_tabla, tipo_operacion
ORDER BY nombre_tabla, tipo_operacion;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Segundo Explain plan(Resumen total de ventas.)

EXPLAIN PLAN FOR
SELECT p.nombre, SUM(dp.cantidad) AS total_unidades, SUM(dp.cantidad * dp.precio_unitario) AS total_ventas
FROM detalles_pedido dp
JOIN productos p ON dp.producto_id = p.producto_id
GROUP BY p.nombre
ORDER BY total_ventas DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

--Tercer Explain Plan

EXPLAIN PLAN FOR
SELECT p.pedido_id, p.fecha_pedido, p.estado, p.total
FROM pedidos p
JOIN usuarios u ON p.usuario_id = u.usuario_id
WHERE u.email = 'benja.lopez@cliente.com';

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
/



