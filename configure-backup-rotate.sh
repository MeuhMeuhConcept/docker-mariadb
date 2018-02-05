#!/bin/sh
set -e

MYSQL_DATABASE=${MYSQL_DATABASE:-""}

if [ "$MYSQL_DATABASE" == "" ]; then
    read -p "What is your database name ? " MYSQL_DATABASE
fi

if [ ! -d /var/backups ]; then
    mkdir /var/backups
fi

DUMP_FILE=/var/backups/$MYSQL_DATABASE.sql
BACKUP_FILE=$DUMP_FILE.gz
LOGROTATE_FILE=/etc/logrotate.d/$MYSQL_DATABASE-dump

if [ -e $LOGROTATE_FILE ]; then
    echo "[i] $LOGROTATE_FILE already present, skipping creation"
else
    echo "[i] $LOGROTATE_FILE not found, creating file"
    if [ ! -e $BACKUP_FILE ];
    then
        echo "Create an empty file $BACKUP_FILE"
        touch $BACKUP_FILE
    fi


    cat << EOF > $LOGROTATE_FILE
$BACKUP_FILE {
    daily
    rotate 7
    nocompress
    create 640 root root
    postrotate
        mysqldump -u root $MYSQL_DATABASE > $DUMP_FILE
        gzip -9f $DUMP_FILE
    endscript
}
EOF

    logrotate -vf $LOGROTATE_FILE
fi

crond_running=$(ps aux | grep crond | wc -l)
if [ $crond_running == 1 ]; then
    echo "crond is not running, we start it"
    crond
fi
