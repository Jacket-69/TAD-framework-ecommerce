# Script de inicialización automático para la base de datos.
# Este script se ejecuta UNA SOLA VEZ cuando la base de datos se crea por primera vez.

# Esperamos un momento para asegurarnos de que la BD esté receptiva 😏.
sleep 20 

# La contraseña para SYS la toma del docker-compose.yml.
# El "-s" en sqlplus es para modo "silencioso", para no llenar la consola de porquería wuajaj.
echo "--- [Paso 1/2] Ejecutando 01_crear_schema.sql como SYS ---"

# Añadimos @//localhost:1521/XEPDB1 para conectar SYS directamente a la PDB.
sqlplus -s sys/"$ORACLE_PWD"@//localhost:1521/XEPDB1 as sysdba <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE;
@/app/sql/01_crear_schema.sql
EXIT;
EOF

# Verificamos si el primer script falló.
if [ $? -ne 0 ]; then
    echo "ERROR: Falló la creación del schema 😰. Revisa 01_crear_schema.sql."
    exit 1
fi

# Ahora, nos conectamos como el usuario que acabamos de crear para ejecutar el segundo script.
echo "--- [Paso 2/2] Ejecutando 02_crear_tablas.sql como ECOMMERCE_FRAMEWORK ---"
sqlplus -s ECOMMERCE_FRAMEWORK/framework123@//localhost:1521/XEPDB1 <<EOF
WHENEVER SQLERROR EXIT SQL.SQLCODE;
@/app/sql/02_crear_tablas.sql
EXIT;
EOF

# Verificamos si el segundo script falló.
if [ $? -ne 0 ]; then
    echo "ERROR: Falló la creación de tablas 😭. Revisa 02_crear_tablas.sql."
    exit 1
fi

echo ""
echo "¡Listaylor! La base de datos ha sido inicializada y está lista para usar. 😈"
echo "Puedes conectarte con el usuario: ECOMMERCE_FRAMEWORK"
echo "Pero la contraseña no te la puedo decir. 😭"