# MySQL Scheduled Exporter

This project provides a Docker-based solution for scheduling exports of MySQL databases. It leverages a custom exporter service that connects to a MySQL database, performs exports at scheduled intervals, and saves the exported data to a specified directory while also compressing and encoding the exported file.

### Prerequisites

- Docker and Docker Compose installed on your system.
- Access to a MySQL or MariaDB database for exporting.

### Usage

You can use the docker image in an existing docker-compose file that contains a MySQL docker image. The example shows exactly this: the exporter service connects to the database and exports the database at regular intervals.

```yml
services:
  db:
    image: 'mariadb:10-focal'
    environment:
      - MYSQL_ROOT_PASSWORD=test

  exporter:
    image: 'janezs12/mysql-scheduled-exporter:latest'
    environment:
      - DB_HOST=db
      - DB_USER=root
      - DB_PASSWORD=test
      - DB_NAME=sys
      - SALT=salt
    volumes:
      - '/home/exports/:/exporter/data/' # host directory mapped for exported data
      - '/exporter/schedule.cron:/exporter/schedule.cron' # optional if you want to use custom schedule
    ports:
      - '5050:80' # healthcheck server port
    depends_on:
      - db
```

The `schedule.cron` file should mostly stay the same, the only difference should be the schedule you set. The example below is scheduled to run every Sunday at 3am (this is also the default config).

```
0 3 * * 0 /bin/sh /exporter/export.sh >> /exporter/logs/exporter.log 2>&1

```

### Health Check

The container provides a health check endpoint accessible at `http://<IP>:80/health`. This endpoint checks if the cron service is running and if the exporter job (`/exporter/export.sh`) is scheduled in the crontab. If both conditions are met, the endpoint returns a status code of `200 OK`, indicating that the exporter job is running and scheduled correctly. If either the cron service is not running or the exporter job is not scheduled, the endpoint will return an error status code, indicating an issue with the health of the service.

### License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

