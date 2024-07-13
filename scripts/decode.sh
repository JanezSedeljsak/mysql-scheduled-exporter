#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <encrypted_filename>"
    exit 1
fi

FILENAME=$1
TMP_DIR="/exporter/tmp/"
EXPORT_DIR="/exporter/data/"

SQL_FILE="${EXPORT_DIR}${FILENAME}.sql"
SQL_ENC_FILE="${TMP_DIR}${FILENAME}.sql.enc"
SQL_ENC_ZSTD_FILE="${EXPORT_DIR}${FILENAME}.sql.enc.zst"

zstd -d "${SQL_ENC_ZSTD_FILE}" -o "${SQL_ENC_FILE}"
echo "[DB-EXPORTER-$(date -u +"%Y%m%d%H%M")] 1. File decompressed."

openssl aes-256-cbc -d -a -salt -k "${SALT}${FILENAME}" -in "${SQL_ENC_FILE}" -out "${SQL_FILE}"
echo "[DB-EXPORTER-$(date -u +"%Y%m%d%H%M")] 2. File decrypted."

rm -f "${SQL_ENC_FILE}"
echo "[DB-EXPORTER-$(date -u +"%Y%m%d%H%M")] 3. Deleted temp files."