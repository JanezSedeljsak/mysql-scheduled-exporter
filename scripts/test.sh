#!/bin/bash

rm -rf /exporter/data/*

printenv > /etc/environment
sh export.sh

file_count=$(find /exporter/data -maxdepth 1 -type f | wc -l)
if [ "$file_count" -eq 1 ]; then
    exported_filename=$(basename "$(find /exporter/data -type f)" .sql.enc.zst)
    echo "Exported filename: $exported_filename"
else
    echo "Error: There should be exactly one file in /exporter/data, but found $file_count."
    exit 1
fi

sh decode.sh "$exported_filename"
decoded="/exporter/data/${exported_filename}.sql"
raw_dump="/exporter/data/raw-dump.sql"

mysqldump --host="$DB_HOST" --databases "$DB_NAME" -u "$DB_USER" -p"$DB_PASSWORD" > "$raw_dump"

diffs=$(diff $raw_dump $decoded | grep -vE 'raw-dump|sys-dump|Dump completed' | wc -l)
if [ "$diffs" -gt 4 ]; then
    echo "Error: Decoded file doesn't match the raw export of the database dump."
    exit 1
else
    echo "DB export was successfully exported, encoded, zipped, and then reverted to the raw SQL."
fi

crond -f -d 8 &
/exporter/healthserver &

# wait for server to startup
sleep 10

response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80/health)
if [ "$response" -ne 200 ]; then
    echo "Health check failed with status: $response"
    exit 1
else
    echo "Health check passed with status: $response"
fi

echo "Done with tests :)"
exit 0