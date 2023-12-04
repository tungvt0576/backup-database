FROM alpine:latest

ARG BACKUP_USER=root
ENV HOSTNAME=pgsql
ENV PG_USERNAME=pgsql
ENV PG_PASSWORD=secret
ENV PG_DATABASE=pgsql
ENV BACKUP_DIR=/data
ENV PG_ENABLE_CUSTOM_BACKUPS=yes
ENV PG_ENABLE_PLAIN_BACKUPS=no
ENV PG_DAY_OF_WEEK_TO_KEEP=5
ENV PG_DAYS_TO_KEEP=7
ENV PG_WEEKS_TO_KEEP=5
ENV CRON_EXPRESSION="0 4 * * *"

RUN apk add --update --no-cache postgresql-client

VOLUME /data

ADD postgresql_backup.sh /usr/local/bin/postgresql_backup

RUN echo "$CRON_EXPRESSION postgresql_backup" > /var/spool/cron/crontabs/$BACKUP_USER

USER $BACKUP_USER

CMD ["crond", "-l2", "-f"]
