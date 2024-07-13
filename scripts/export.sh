#!/bin/bash

EXPORT_FILENAME="${DB_NAME}-dump-$(date -u +"%Y%m%d%H%M")"
TMP_DIR="/exporter/tmp/"
EXPORT_DIR="/exporter/data/"

SQL_FILE="${TMP_DIR}${EXPORT_FILENAME}.sql"
SQL_ENC_FILE="${TMP_DIR}${EXPORT_FILENAME}.sql.enc"
SQL_ENC_ZSTD_FILE="${EXPORT_DIR}${EXPORT_FILENAME}.sql.enc.zst"

echo "[DB-EXPORTER] Will try to create a ${EXPORT_FILENAME}"

mysqldump --host=$DB_HOST --databases $DB_NAME -u $DB_USER -p$DB_PASSWORD > "${SQL_FILE}"
echo "[DB-EXPORTER-$(date -u +"%Y%m%d%H%M")] 1. Database exported successfully."

openssl aes-256-cbc -a -salt -pbkdf2 -iter 10000 -k "${SALT}${EXPORT_FILENAME}" -in "${SQL_FILE}" -out "${SQL_ENC_FILE}"
echo "[DB-EXPORTER-$(date -u +"%Y%m%d%H%M")] 2. Compressed successfully (${SQL_ENC_FILE})"

zstd -z -q "${SQL_ENC_FILE}" -o "${SQL_ENC_ZSTD_FILE}"
echo "[DB-EXPORTER-$(date -u +"%Y%m%d%H%M")] 3. File compressed successfully."

rm -f "${SQL_FILE}"
rm -f "${SQL_ENC_FILE}"
echo "[DB-EXPORTER-$(date -u +"%Y%m%d%H%M")] 4. Deleted temp files."