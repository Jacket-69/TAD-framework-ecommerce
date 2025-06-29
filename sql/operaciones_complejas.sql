--Consultas Analiticas Complejas-

--Identificar los cambios(Update,Delete,Insert) por tabla

SELECT nombre_tabla, usuario_accion, total_operaciones
FROM (
    SELECT 
        nombre_tabla,
        usuario_accion,
        COUNT(*) AS total_operaciones,
        RANK() OVER (PARTITION BY nombre_tabla ORDER BY COUNT(*) DESC) AS ranking
    FROM tabla_auditoria
    GROUP BY nombre_tabla, usuario_accion
)
WHERE ranking <= 3
ORDER BY nombre_tabla, total_operaciones DESC;
/


--Consulta sobre Resumen mensual de operaciones por tipo y tabla

SELECT
    TO_CHAR(fecha_accion, 'YYYY-MM') AS mes,
    nombre_tabla,
    tipo_operacion,
    COUNT(*) AS total_operaciones
FROM tabla_auditoria
WHERE fecha_accion >= ADD_MONTHS(SYSDATE, -6)
GROUP BY TO_CHAR(fecha_accion, 'YYYY-MM'), nombre_tabla, tipo_operacion
ORDER BY mes DESC, nombre_tabla, tipo_operacion;
/