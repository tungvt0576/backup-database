docker run --env HOSTNAME=192.168.0.125:5432 \
    --env ROOT_DATABASE=mci \
    --env PG_USERNAME=dev \
    --env PG_PASSWORD=1 \
    --volume /home/das/backup:/data \
    --name backup-database \
    -d tungvt200576/backup-database:1.0