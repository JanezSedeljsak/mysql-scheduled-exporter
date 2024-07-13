#!/bin/bash

echo "Starting the health server and cron..."

/exporter/healthserver &

printenv > /etc/environment
crond -f -d 8