#!/bin/bash

###########################
#### PRE-BACKUP CHECKS ####
###########################

# Ensure the script is run with the required backup user
if [ "$PG_BACKUP_USER" != "" ] && [ "$(id -un)" != "$PG_BACKUP_USER" ]; then
    echo "This script must be run as $PG_BACKUP_USER. Exiting." >&2
    exit 1
fi

###########################
### INITIALISE DEFAULTS ###
###########################

HOSTNAME="${HOSTNAME:-localhost}"
PG_USERNAME="${PG_USERNAME:-postgres}"
BACKUP_DIR="${BACKUP_DIR%/}/"
PG_OPTIONS="-h $HOSTNAME -U $PG_USERNAME"

###########################
#### START THE BACKUPS ####
###########################

function perform_backups() {
    SUFFIX=$1
    FINAL_BACKUP_DIR="${BACKUP_DIR}$(date +\%Y-\%m-\%d)$SUFFIX/"

    echo "Making backup directory in $FINAL_BACKUP_DIR"

    if ! mkdir -p "$FINAL_BACKUP_DIR"; then
        echo "Cannot create backup directory in $FINAL_BACKUP_DIR. Fix the issue!" >&2
        exit 1
    fi

    ###########################
    ##### DATABASE BACKUPS #####
    ###########################

    FULL_BACKUP_QUERY="SELECT datname FROM pg_database WHERE datistemplate = false;"

    echo -e "\n\nPerforming full backups"
    echo -e "--------------------------------------------\n"

    for DATABASE in $(psql $PG_OPTIONS -t -c "$FULL_BACKUP_QUERY"); do
        if [ "$DATABASE" == "$ROOT_DATABASE" ] || [ "$DATABASE" == "$SQL_DATABASE" ]; then
            if [ "$PG_ENABLE_PLAIN_BACKUPS" = "yes" ]; then
                echo "Plain backup of $DATABASE"

                if ! pg_dump $PG_OPTIONS -F c "$DATABASE" | gzip > "$FINAL_BACKUP_DIR$DATABASE.sql.gz.in_progress"; then
                    echo "[!!ERROR!!] Failed to produce plain backup of database $DATABASE" >&2
                else
                    mv "$FINAL_BACKUP_DIR$DATABASE.sql.gz.in_progress" "$FINAL_BACKUP_DIR$DATABASE.sql.gz"
                fi
            fi

            if [ "$PG_ENABLE_CUSTOM_BACKUPS" = "yes" ]; then
                echo "Custom backup of $DATABASE"

                if ! pg_dump $PG_OPTIONS -F c "$DATABASE" | gzip > "$FINAL_BACKUP_DIR$DATABASE.custom.in_progress"; then
                    echo "[!!ERROR!!] Failed to produce custom backup of database $DATABASE" >&2
                else
                    mv "$FINAL_BACKUP_DIR$DATABASE.custom.in_progress" "$FINAL_BACKUP_DIR$DATABASE.custom"
                fi
            fi
        fi
    done

    echo -e "\nAll database backups complete!"
}

# MONTHLY BACKUPS

DAY_OF_MONTH=$(date +%d)

if [ "$DAY_OF_MONTH" -eq 1 ]; then
    # Delete all expired monthly directories
    find "$BACKUP_DIR" -maxdepth 1 -name "*-monthly" -exec rm -rf '{}' ';'

    perform_backups "-monthly"

    exit 0
fi

# WEEKLY BACKUPS

DAY_OF_WEEK=$(date +%u) # 1-7 (Monday-Sunday)
EXPIRED_DAYS=$((($PG_WEEKS_TO_KEEP * 7) + 1))

if [ "$DAY_OF_WEEK" -eq "$PG_DAY_OF_WEEK_TO_KEEP" ]; then
    # Delete all expired weekly directories
    find "$BACKUP_DIR" -maxdepth 1 -mtime +$EXPIRED_DAYS -name "*-weekly" -exec rm -rf '{}' ';'

    perform_backups "-weekly"

    exit 0
fi

# DAILY BACKUPS

# Delete daily backups 7 days old or more
find "$BACKUP_DIR" -maxdepth 1 -mtime +$PG_DAYS_TO_KEEP -name "*-daily" -exec rm -rf '{}' ';'

perform_backups "-daily"
