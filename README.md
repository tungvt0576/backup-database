# RUN COMMAND
```
docker run -e HOSTNAME=192.168.0.125 \
           -e ROOT_DATABASE=mci \
           -e PG_USERNAME=dev \
           -e PG_PASSWORD=1 \
           -e CRON_EXPRESSION="0 * * * *" \
           -e SCHEMA="mci-dev" \
           -v /home/das/backup:/data \
           --name backup-database \
           -d tungvt200576/backup-database
```
