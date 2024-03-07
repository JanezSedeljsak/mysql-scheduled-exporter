#!/bin/bash

if [ -f ../.env ]; then
    export $(cat ../.env | xargs)
else
    echo "Missing .env!"
    exit 1
fi

network_name="dbexporter_DBExporterNetwork"
network_id=$(docker network ls --filter name=${network_name} --format "{{.ID}}")

# Check if the network exists
if [ -z "${network_id}" ]; then
    echo "Network '${network_name}' not found. Please check the network name."
    exit 1
fi

# Check if the container is already connected to the network
docker inspect -f "{{.NetworkSettings.Networks.${network_name}}}" ${EXPORT_DB_CONTAINER}
conn_status=$?
if [ "${conn_status}" == "0" ]; then
    echo "Container is already connected to network '${network_name}'."
    exit 0
else
    echo "Container has to be added to the network."
fi

# Add the container to the network
docker network connect "$network_name" "$EXPORT_DB_CONTAINER"

# Check if the container was added to the network
docker inspect -f "{{.NetworkSettings.Networks.${network_name}}}" ${EXPORT_DB_CONTAINER}
conn_status=$?
if [ "${conn_status}" == "0" ]; then
    echo "Container '${EXPORT_DB_CONTAINER}' successfully added to network '${network_name}'."
    exit 0
else
    echo "Failed to add container '${EXPORT_DB_CONTAINER}' to network '${network_name}'."
    exit 1
fi