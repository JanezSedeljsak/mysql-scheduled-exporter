#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <encrypted_filename> <output_path>"
    exit 1
fi

if [ -f ../.env ]; then
    export $(cat ../.env | xargs)
else
    echo "Missing .env!"
    exit 1
fi

encrypted_filename="$1"
output_path="$2"
output_filename="$(basename "$encrypted_filename" .enc)"
openssl aes-256-cbc -d -a -k "$ENCRYPTION_SALT$(basename "$output_filename" .sql)" -in "$encrypted_filename" -out "$output_path$output_filename"
echo "Decryption completed. Output filename: $output_filename"