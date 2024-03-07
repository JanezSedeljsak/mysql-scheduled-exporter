#!/bin/bash

# this needs to be executed inside a docker container
if [ -f /exporter/.env ]; then
    export $(cat /exporter/.env | xargs)
else
    echo "Missing .env!"
    exit 1
fi

export_filename="dump-$(date -u +"%Y%m%d%H%M")".sql
echo "Will try to create a $export_filename"
if [ -n "$EXPORT_DB_CONTAINER" ]; then
    mysqldump --host=$EXPORT_DB_CONTAINER --databases $EXPORTER_MYSQL_DATABASE -u $EXPORTER_MYSQL_USER -p$EXPORTER_MYSQL_PASSWORD > "/exporter/raw/$export_filename"
    echo "[1] Database exported successfully."

    openssl aes-256-cbc -a -salt -k "$ENCRYPTION_SALT$(basename "$export_filename" .sql)" -in "/exporter/raw/$export_filename" -out "/exporter/data/$export_filename.enc"
    echo "[2] DB file encoded successfully ($EXPORT_DIRECTORY$export_filename.enc)."
    
    rm "/exporter/raw/$export_filename"
    echo "[3] DB file deleted successfully."
else
    echo "Error: Container not found. Make sure the container is running."
fi