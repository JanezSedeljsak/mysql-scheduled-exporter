FROM ubuntu:20.04

RUN apt-get update && \
    apt-get install -y \
    cron \
    openssl \
    iputils-ping \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /exporter
RUN mkdir -p /exporter/data /exporter/scripts /exporter/raw /exporter/logs

COPY ./scripts/run.sh /exporter/scripts/run.sh
COPY .env /exporter/.env

RUN chmod +x /exporter/scripts/run.sh
COPY cronjob /etc/cron.d/export-cron

RUN chmod 0644 /etc/cron.d/export-cron
RUN touch /var/log/cron.log

WORKDIR /exporter
ENTRYPOINT printenv > /etc/environment && crontab /etc/cron.d/export-cron && cron -f