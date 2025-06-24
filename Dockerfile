# Dockerfile para el Proyecto Integrador
# Solución multi-etapa para problemas de permisos en Windows 🫠

# --- ETAPA 1: Preparar el script en un entorno Linux limpio ---
# Usamos una imagen mínima de 'busybox' para esta tarea.
FROM busybox:latest AS preparer
# Copiamos nuestro script al contenedor temporal.
COPY ./entrypoint.sh /entrypoint.sh
# Le damos permisos de ejecución dentro de este entorno aislado. 
RUN chmod +x /entrypoint.sh

# --- ETAPA 2: Construir la imagen final de Oracle ---
# Empezamos desde la base de Oracle como siempre.
FROM container-registry.oracle.com/database/express:21.3.0-xe

# Copiamos nuestros scripts SQL. Esto no cambia.
COPY ./sql /app/sql

# copiamos el script YA EJECUTABLE desde la Etapa 1.
COPY --from=preparer /entrypoint.sh /opt/oracle/scripts/startup/
