## MySQL DB Exporter

This repository contains a straightforward Docker container designed for effortlessly exporting data from a specified database at regular intervals, facilitated by a cron job.

### Prerequisites

Before running the exporter, make sure to set up the essential environment variables in the `.env` file. Below are the variables required:

```bash
EXPORTER_MYSQL_USER=root
EXPORTER_MYSQL_PASSWORD=root
EXPORTER_MYSQL_DATABASE=smthn

EXPORT_ENCRYPTION_SALT=salt
EXPORT_DIRECTORY=/home/exports/
EXPORT_DB_CONTAINER=43242dsf342
```

### Setting up the Exporter

Follow these steps to execute the exporter:

1. Build the Docker container
```bash
docker-compose -p dbexporter up --build
```

2. Execute the post-build script (add the db to the exporter network)
```bash
cd scripts
chmod +x post-build.sh
./post-build.sh
```

### Decoding files

If you want to decode the exported files you simply run:

```bash
cd scripts
chmod +x decode.sh
./decode.sh <encrypted_filename> <output_path>
```