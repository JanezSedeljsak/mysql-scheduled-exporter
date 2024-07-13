FROM alpine:3.14

RUN apk update && \
    apk add --no-cache \
    mariadb-client \
    busybox \
    openssl \
    zstd \
    go \
    nano \
    curl \
    && rm -rf /var/cache/apk/*

WORKDIR /exporter

RUN rm -rf /exporter/tmp && mkdir -p /exporter/tmp /exporter/data /exporter/logs

COPY ./scripts /exporter
COPY ./api/server.go /exporter/server.go
COPY ./schedule.cron /exporter/schedule.cron

# add execute permission to scripts
RUN chmod +x /exporter/export.sh
RUN chmod +x /exporter/decode.sh
RUN chmod +x /exporter/start.sh
RUN chmod +x /exporter/test.sh
RUN chmod +x /exporter/schedule.cron

# schedule cron and build healthcheck server
RUN crontab /exporter/schedule.cron
RUN go build -o /exporter/healthserver /exporter/server.go

CMD ["sh", "/exporter/start.sh"]