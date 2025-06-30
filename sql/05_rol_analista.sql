--Consulta con respecto a 10 usuarios con mayor venta, filtrado por tienda y con comprobacion para "Analista".

SELECT *
FROM (
    SELECT 
        u.usuario_id,
        u.nombre,
        u.apellido,
        u.email,
        SUM(dp.cantidad * dp.precio_unitario) AS total_vendido
    FROM pedidos p
    JOIN usuarios u ON p.usuario_id = u.usuario_id
    JOIN detalles_pedido dp ON dp.pedido_id = p.pedido_id AND dp.fecha_pedido_fk = p.fecha_pedido
    WHERE u.tienda_id = (
        SELECT t.tienda_id
        FROM usuarios u2
        JOIN usuario_roles ur ON ur.usuario_id = u2.usuario_id
        JOIN roles r ON r.rol_id = ur.rol_id
        JOIN tiendas t ON t.tienda_id = u2.tienda_id
        WHERE u2.email = SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER')
          AND r.nombre_rol = 'Analista'
        FETCH FIRST 1 ROWS ONLY
    )
    AND p.fecha_pedido >= TRUNC(ADD_MONTHS(SYSDATE, -1))
    GROUP BY u.usuario_id, u.nombre, u.apellido, u.email
    ORDER BY total_vendido DESC
)
WHERE ROWNUM <= 10;

--Consulta con respecto a Productos mas vendidos y region que se vende.

SELECT 
    p.nombre AS producto,
    d.region,
    SUM(dp.cantidad) AS total_vendido
FROM pedidos pe
JOIN usuarios u ON pe.usuario_id = u.usuario_id
JOIN direcciones d ON u.usuario_id = d.usuario_id
JOIN detalles_pedido dp ON dp.pedido_id = pe.pedido_id AND dp.fecha_pedido_fk = pe.fecha_pedido
JOIN productos p ON p.producto_id = dp.producto_id
WHERE u.tienda_id = (
    SELECT t.tienda_id
    FROM usuarios u2
    JOIN usuario_roles ur ON ur.usuario_id = u2.usuario_id
    JOIN roles r ON r.rol_id = ur.rol_id
    JOIN tiendas t ON t.tienda_id = u2.tienda_id
    WHERE u2.email = SYS_CONTEXT('USERENV', 'CLIENT_IDENTIFIER')
      AND r.nombre_rol = 'Analista'
    FETCH FIRST 1 ROWS ONLY
)
AND pe.fecha_pedido >= TRUNC(ADD_MONTHS(SYSDATE, -1)) -- solo último mes
GROUP BY p.nombre, d.region
ORDER BY total_vendido DESC;
