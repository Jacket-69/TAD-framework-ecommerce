
# Script de inicialización automática para la base de datos ECOMMERCE_FRAMEWORK.

# Esperamos unos segundos por si la BD está recién iniciando (contenedores, etc.).
sleep 10

echo "--- Verificando estado del schema ECOMMERCE_FRAMEWORK... ---"

# Consultamos si el usuario ya existe
USER_EXISTS=$(sqlplus -s sys/"$ORACLE_PWD"@//localhost:1521/XEPDB1 as sysdba <<EOF
  set heading off feedback off pagesize 0 verify off;
  SELECT 'EXISTE' FROM dba_users WHERE username = 'ECOMMERCE_FRAMEWORK';
  exit;
EOF
)

# Si el usuario NO existe, lo creamos y configuramos
if [[ -z "$USER_EXISTS" ]]; then
  echo "--- Schema no encontrado. Iniciando creación por primera vez... ---"

  # PASO 1: Crear el usuario y otorgar permisos
  echo "--> Ejecutando 01_crear_schema.sql como SYS..."
  sqlplus -s sys/"$ORACLE_PWD"@//localhost:1521/XEPDB1 as sysdba @/app/sql/01_crear_schema.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación del schema 😰. Revisa 01_crear_schema.sql."
    exit 1
  fi

  # PASO 2: Crear las tablas, vistas, triggers, roles, funciones, etc.
  echo "--> Ejecutando 02_crear_tablas.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/02_crear_tablas.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación de tablas 😭. Revisa 02_crear_tablas.sql."
    exit 1
  fi

  # PASO 3: (Opcional) crear vistas o índices adicionales
  echo "--> Ejecutando 04_optimizacion_vistas.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/04_optimizacion_vistas.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación de vistas o índices 😡. Revisa 04_optimizacion_vistas.sql."
    exit 1
  fi

    # PASO 4: Ejecutar Backup RMAN
  echo "--> Ejecutando 09_backuo_rman como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/09_backup_rman.sh
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló del script 😡. Revisa 09_backup_rman.sh"
    exit 1
  fi

  echo ""
  echo "✅ ¡Listaylor! ✅"
  echo "La base de datos ha sido creada y estructurada exitosamente. 😈"
  echo "Puedes conectarte con el usuario: ECOMMERCE_FRAMEWORK"
  echo "Pero la contraseña no te la puedo decir. 😭"

else
  echo "--- El schema ECOMMERCE_FRAMEWORK ya existe. No se realizará ninguna acción. ---"
  echo "✅ ¡Listaylor! ✅"
  echo "La base de datos ya estaba lista para usarse. 😈"
fi
