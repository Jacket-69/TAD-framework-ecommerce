#!/bin/bash
# ===================================================================
# SCRIPT DE RESPALDO FÍSICO (RMAN)
# ===================================================================
BACKUP_DIR="/opt/oracle/oradata/dpdump"
TIMESTAMP=$(date +"%Y%m%d")
BACKUP_TAG="FULL_DB_BACKUP_${TIMESTAMP}"

echo "--- Iniciando Respaldo Físico Completo con RMAN ---"
rman target / <<EOF
RUN {
  -- Configura una política de retención de 7 días
  CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 7 DAYS;

  -- Respalda la base de datos completa y los logs necesarios
  BACKUP AS COMPRESSED BACKUPSET DATABASE PLUS ARCHIVELOG TAG '${BACKUP_TAG}';

  -- Limpia los respaldos antiguos automáticamente
  DELETE NOPROMPT OBSOLETE;
}
EXIT;
EOF
echo " Respaldo físico con RMAN completado."
