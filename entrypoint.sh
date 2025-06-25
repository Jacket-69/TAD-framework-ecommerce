# Script de inicialización automático para la base de datos.

# Esperamos un momento para asegurarnos de que la BD esté receptiva 😏.
sleep 10

echo "--- Verificando estado del schema ECOMMERCE_FRAMEWORK... ---"

# Usamos SQL*Plus para PREGUNTAR si el usuario existe.
# El resultado lo guardamos en una variable.
# Terrible no hago esta parte nunca más.
USER_EXISTS=$(sqlplus -s sys/"$ORACLE_PWD"@//localhost:1521/XEPDB1 as sysdba <<EOF
  set heading off feedback off pagesize 0 verify off;
  select 'EXISTE' from dba_users where username = 'ECOMMERCE_FRAMEWORK';
  exit;
EOF
)

# Ahora, en la seguridad de nuestro script bash, tomamos la decisión.
# El -z "$USER_EXISTS" comprueba si la variable está vacía (o sea, si el usuario NO existe).
if [[ -z "$USER_EXISTS" ]]; then
  echo "--- Schema no encontrado. Iniciando creación por primera vez... ---"
  
  # --- PASO 1: Crear el Schema ---
  echo "--> Ejecutando 01_crear_schema.sql como SYS..."
  # Usamos el script tal cual
  sqlplus -s sys/"$ORACLE_PWD"@//localhost:1521/XEPDB1 as sysdba @/app/sql/01_crear_schema.sql
  # Verificamos si el paso anterior tuvo éxito.
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación del schema 😰. Revisa 01_crear_schema.sql."
    exit 1
  fi

  # --- PASO 2: Crear las Tablas ---
  echo "--> Ejecutando 02_crear_tablas.sql como ECOMMERCE_FRAMEWORK..."
  sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 @/app/sql/02_crear_tablas.sql
  if [ $? -ne 0 ]; then
    echo "❌ ERROR: Falló la creación de tablas 😭. Revisa 02_crear_tablas.sql."
    exit 1
  fi

  echo ""
    echo "✅ ¡Listaylor! ✅"
    echo "La base de datos ha sido inicializada y está lista para usarse. 😈"
    echo "Puedes conectarte con el usuario: ECOMMERCE_FRAMEWORK"
    echo "Pero la contraseña no te la puedo decir. 😭"

else
  # Si la variable USER_EXISTS tenía algo, significa que el usuario ya estaba.
  echo "--- El schema ya existe. No se hará nada. ---"
  echo "✅ ¡Listaylor! ✅"
  echo "La base de datos ha sido inicializada y está lista para usarse. 😈"
  echo "Puedes conectarte con el usuario: ECOMMERCE_FRAMEWORK"
  echo "Pero la contraseña no te la puedo decir. 😭"
fi