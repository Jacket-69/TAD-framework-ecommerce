--Creacion de vistas para reportes utiles.
--Se mostrara un resumen de Cantidad total de pedidos por usuario.
--Total acumulado de compras.
--Fecha de ultimo pedido.
--Estado mas reciente.

CREATE OR REPLACE VIEW vw_resumen_pedidos_usuario AS
SELECT
    u.usuario_id,
    u.nombre || ' ' || u.apellido AS nombre_completo,
    u.email,
    COUNT(p.pedido_id) AS total_pedidos,
    SUM(p.total) AS total_comprado,
    MAX(p.fecha_pedido) AS fecha_ultimo_pedido,
    MAX(p.estado) KEEP (DENSE_RANK LAST ORDER BY p.fecha_pedido) AS estado_ultimo_pedido
FROM usuarios u
LEFT JOIN pedidos p ON u.usuario_id = p.usuario_id
GROUP BY u.usuario_id, u.nombre, u.apellido, u.email;
/

--Ejemplo de uso de vista resumen.
--SELECT * FROM vw_resumen_pedidos_usuario
--WHERE total_pedidos >= 1
--ORDER BY total_comprado DESC;
--/

--Segunda vista para producto mas vendido.

CREATE OR REPLACE VIEW vw_productos_mas_vendidos AS
SELECT
    p.producto_id,
    p.nombre AS nombre_producto,
    p.precio,
    p.stock,
    SUM(dp.cantidad) AS total_vendido,
    SUM(dp.cantidad * dp.precio_unitario) AS total_ingresos
FROM productos p
JOIN detalles_pedido dp ON p.producto_id = dp.producto_id
GROUP BY p.producto_id, p.nombre, p.precio, p.stock;
/

--Ejemplo de uso
--SELECT * 
--FROM vw_productos_mas_vendidos
--ORDER BY total_vendido DESC
--FETCH FIRST 10 ROWS ONLY;
--/