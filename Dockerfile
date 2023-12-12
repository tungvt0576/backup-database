FROM alpine:latest

ARG BACKUP_USER=root
ENV HOSTNAME=pgsql
ENV PORT=5432
ENV PG_USERNAME=pgsql
ENV PG_PASSWORD=secret
ENV SQL_DATABASE=postgres
ENV SCHEMA=public
ENV BACKUP_DIR=/data
ENV PG_ENABLE_CUSTOM_BACKUPS=no
ENV PG_ENABLE_PLAIN_BACKUPS=yes
ENV PG_DAY_OF_WEEK_TO_KEEP=5
ENV PG_DAYS_TO_KEEP=7
ENV PG_WEEKS_TO_KEEP=5
ENV CRON_EXPRESSION="* * * * *"

RUN apk add --update --no-cache postgresql-client

VOLUME /data

ADD postgresql_backup.sh /usr/local/bin/postgresql_backup
RUN chmod +x /usr/local/bin/postgresql_backup

RUN echo "$CRON_EXPRESSION sh /usr/local/bin/postgresql_backup" > /var/spool/cron/crontabs/$BACKUP_USER

USER $BACKUP_USER

CMD ["crond", "-l","8", "-f"]
