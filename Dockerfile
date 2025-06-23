# Dockerfile para el Proyecto Integrador
# Usa la imagen oficial de Oracle 21c Express Edition como base.
FROM container-registry.oracle.com/database/express:21.3.0-xe

# Exponer el puerto 1521 para que la base de datos sea accesible.
EXPOSE 1521
