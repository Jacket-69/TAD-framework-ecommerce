
# ===================================================================
# SCRIPT DE RECUPERACIÓN FÍSICA (RMAN),
# ¡ADVERTENCIA! Este script es para recuperación ante desastres y
# debe ser ejecutado por un DBA con extrema precaución.
# ===================================================================

echo "--- ¡ADVERTENCIA! Este proceso restaurará la base de datos ---"
echo "--- a su último estado respaldado. Es una operación crítica. ---"
read -p "¿Estás seguro de que deseas continuar? (s/n): " confirm
if [[ ! "$confirm" =~ ^[sS]$ ]]; then
  echo "Restauración cancelada."
  exit 0
fi

echo "--- Iniciando Proceso de Recuperación Completa con RMAN ---"
rman target / <<EOF
-- El proceso sigue la secuencia de DBA para recuperación de desastres
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
RUN {
  -- 1. Restaura los archivos de la base de datos desde el último backup
  RESTORE DATABASE;
  -- 2. Aplica los logs para llevar la base de datos a un estado consistente
  RECOVER DATABASE;
}
-- 3. Abre la base de datos para que vuelva a estar disponible
ALTER DATABASE OPEN;
EXIT;
EOF
echo " Proceso de recuperación con RMAN finalizado. La base de datos debería estar en línea."
