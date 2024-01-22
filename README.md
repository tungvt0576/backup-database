# Prerequisites
```
Linux (optional)
Docker
Gdrive
Nano (optional)
```
# Deployment docker-compose
### Step 1: Create backup directory
 First, create the backup directory that Backup Service will use to store its docker-compose.yaml and data:
 ```
 mkdir /path/to/backup
 ```
### Step 2: Create docker-compose.yaml
Then, touch docker-compose.yaml in /path/to/backup
 ```
 cd /path/to/backup
 nano docker-compose.yaml
 ```
Let’s compose a docker-compose.yml file with a services, namely backup-database:
```
version: '3'
services:
  backup-database:
    image: tungvt200576/backup-database
    container_name: backup-database
    environment:
      - HOSTNAME=${HOSTNAME_OF_PGSQL}
      - BACKUP_DATABASE=${DATABASE_NEEDS_BACKUP}
      - PG_USERNAME=${USERNAME}
      - PG_PASSWORD=${PASSWORD}
      - CRON_EXPRESSION="0 * * * *"
      - SCHEMA=${SCHEMA}
    volumes:
      - paht/to/backup:/data
    restart: always

```
### Step 3: Start backup-database service
```
docker-compose -f path/to/docker-compose.yaml up -d

```
# ENV CONTAINER
Explain env
```
HOSTNAME: host name of database
PORT: port of database
PG_USERNAME: database's username 
PG_PASSWORD: database's password 
BACKUP_DATABASE: database needs backup
SCHEMA: schema of the database needs backup
BACKUP_DIR: directory which store backup file.
PG_ENABLE_CUSTOM_BACKUPS: save the backup as custom
PG_ENABLE_PLAIN_BACKUPS: save the backup as plaintext
PG_DAYS_TO_KEEP: appears to be a variable representing the number of days to retain certain backup files
CRON_EXPRESSION: specifies a schedule to run a task 
```
Defalut value
```
ARG BACKUP_USER=root
ENV HOSTNAME=pgsql
ENV PORT=5432
ENV PG_USERNAME=pgsql
ENV PG_PASSWORD=secret
ENV SQL_DATABASE=postgres
ENV BACKUP_DATABASE=postgres
ENV SCHEMA=public
ENV BACKUP_DIR=/data
ENV PG_ENABLE_CUSTOM_BACKUPS=no
ENV PG_ENABLE_PLAIN_BACKUPS=yes
# ENV PG_DAY_OF_WEEK_TO_KEEP=5
ENV PG_DAYS_TO_KEEP=7
# ENV PG_WEEKS_TO_KEEP=5
ENV CRON_EXPRESSION="0 * * * *"
```
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
# Install Gdrive 2.1.2

### Step 1: Dowload file gdrive_2.1.2_linux_amd64.tar.gz
```
wget url/to/gdrive_2.1.2_linux_amd64.tar.gz
```
### Step 2: extract gdrive_2.1.2_linux_amd64.tar.gz
```
tar -zxvf gdrive_2.1.2_linux_amd64.tar.gz
```
### Step 3: Move gdrive to /usr/local/bin
```
sudo mv gdrive /usr/local/bin/gdrive
sudo chmod +x /usr/local/bin/gdrive
```
### Step 4: Add google account
Excute command:
```
gdrive about
```
Then fill value of code which is in google response URL
```
 http://localhost:1/?state=state&code=4/0AfJohXmJxjhho87_F6euT-95QhpDCGxlQZP5FWy2C3npOp-IkHneEVUEvC_2mkCf-HQiQA&scope=https://www.googleapis.com/auth/drive
 Just copy: 4/0AfJohXmJxjhho87_F6euT-95QhpDCGxlQZP5FWy2C3npOp-IkHneEVUEvC_2mkCf-HQiQA
```
### Step 5: Create directory in google drive
```
gdrive [global] mkdir [options] <name>

global:
  -c, --config <configDir>         Application path, default: /Users/<user>/.gdrive
  --refresh-token <refreshToken>   Oauth refresh token used to get access token (for advanced users)
  --access-token <accessToken>     Oauth access token, only recommended for short-lived requests because of short lifetime (for advanced users)
  --service-account <accountFile>  Oauth service account filename, used for server to server communication without user interaction (file is relative to config dir)
  
options:
  -p, --parent <parent>         Parent id of created directory, can be specified multiple times to give many parents
  --description <description>   Directory description

```
Copy the ID of the already created directory.
### Step 6: Crontab for Sync local directory to drive
```
crontab -e
5 * * * * gdrive sync upload --keep-largest paht/to/backup <ID of the already created drive directory>
```
Tutorial 
```
gdrive [global] sync upload [options] <path> <fileId>

global:
  -c, --config <configDir>         Application path, default: /Users/<user>/.gdrive
  --refresh-token <refreshToken>   Oauth refresh token used to get access token (for advanced users)
  --access-token <accessToken>     Oauth access token, only recommended for short-lived requests because of short lifetime (for advanced users)
  --service-account <accountFile>  Oauth service account filename, used for server to server communication without user interaction (file is relative to config dir)
  
options:
  --keep-remote             Keep remote file when a conflict is encountered
  --keep-local              Keep local file when a conflict is encountered
  --keep-largest            Keep largest file when a conflict is encountered
  --delete-extraneous       Delete extraneous remote files
  --dry-run                 Show what would have been transferred
  --no-progress             Hide progress
  --timeout <timeout>       Set timeout in seconds, use 0 for no timeout. Timeout is reached when no data is transferred in set amount of seconds, default: 300
  --chunksize <chunksize>   Set chunk size in bytes, default: 8388608
```
