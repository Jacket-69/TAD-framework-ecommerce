-- ===============================================
-- SCRIPT: Optimización e implementación de vistas
-- ===============================================

PROMPT >>> Creando índices clave para optimización...

-- Índices sugeridos para rendimiento
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_fecha_registro ON usuarios(fecha_registro);

CREATE INDEX idx_productos_nombre ON productos(nombre);
CREATE INDEX idx_productos_precio ON productos(precio);

CREATE INDEX idx_pedidos_fecha ON pedidos(fecha_pedido);
CREATE INDEX idx_pedidos_usuario_estado ON pedidos(usuario_id, estado);

CREATE INDEX idx_pagos_metodo_estado ON pagos(metodo_pago, estado_pago);
CREATE INDEX idx_detalles_pedido_producto ON detalles_pedido(producto_id);
CREATE INDEX idx_direcciones_ciudad ON direcciones(ciudad);

-- Índices para auditoría
CREATE INDEX idx_auditoria_tabla_tipo ON tabla_auditoria(nombre_tabla, tipo_operacion);
CREATE INDEX idx_auditoria_usuario_fecha ON tabla_auditoria(usuario_accion, fecha_accion);
CREATE INDEX idx_auditoria_fecha ON tabla_auditoria(fecha_accion);

PROMPT >>> Índices creados.

-- ===============================================
PROMPT >>> Creando vistas de auditoría por tabla...

-- Vista: Auditoría de tiendas
CREATE OR REPLACE VIEW vw_auditoria_tiendas AS
SELECT auditoria_id, tipo_operacion, registro_id AS tienda_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'tiendas';

-- Vista: Auditoría de usuarios
CREATE OR REPLACE VIEW vw_auditoria_usuarios AS
SELECT auditoria_id, tipo_operacion, registro_id AS usuario_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'usuarios';

-- Vista: Auditoría de productos
CREATE OR REPLACE VIEW vw_auditoria_productos AS
SELECT auditoria_id, tipo_operacion, registro_id AS producto_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'productos';

-- Vista: Auditoría de pedidos
CREATE OR REPLACE VIEW vw_auditoria_pedidos AS
SELECT auditoria_id, tipo_operacion, registro_id AS pedido_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'pedidos';

-- Vista: Auditoría de detalles_pedido
CREATE OR REPLACE VIEW vw_auditoria_detalles_pedido AS
SELECT auditoria_id, tipo_operacion, registro_id AS detalle_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'detalles_pedido';

-- Vista: Auditoría de pagos
CREATE OR REPLACE VIEW vw_auditoria_pagos AS
SELECT auditoria_id, tipo_operacion, registro_id AS pago_id, valores_antiguos, valores_nuevos, usuario_accion, fecha_accion
FROM tabla_auditoria
WHERE nombre_tabla = 'pagos';

PROMPT >>> Vistas de auditoría creadas exitosamente.

-- ===============================================
PROMPT >>> Recolectando estadísticas...

BEGIN
  DBMS_STATS.GATHER_SCHEMA_STATS('ECOMMERCE_FRAMEWORK');
END;
/

PROMPT >>> Optimización completada correctamente. 🎉
