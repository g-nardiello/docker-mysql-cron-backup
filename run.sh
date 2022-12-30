#!/bin/bash
tail -F /mysql_backup.log &

if ! [ -z "${INIT_BACKUP}" ]; then
  echo "=> Create a backup on the startup"
  /backup.sh
elif ! [ -z "${INIT_RESTORE_LATEST}" ]; then
  echo "=> Restore latest backup"
  until nc -z "$MYSQL_HOST" "$MYSQL_PORT"
  do
      echo "waiting database container..."
      sleep 1
  done
  find /backup -maxdepth 1 -name '*.sql.gz' | tail -1 | xargs /restore.sh
fi

function final_backup {
    DATE=$(date +%Y%m%d%H%M)
    echo "=> Requested last backup at $(date "+%Y-%m-%d %H:%M:%S")"
    exec /backup.sh
    exit 0
}

if ! [ -z "${EXIT_BACKUP}" ]; then
  echo "=> Listening on container shutdown gracefully to make last backup before close"
  trap final_backup SIGHUP SIGINT SIGTERM
fi

echo "${CRON_TIME} /backup.sh >> /mysql_backup.log 2>&1" > /tmp/crontab.conf
crontab /tmp/crontab.conf
echo "=> Running cron task manager in foreground"
# exec crond -f -l 8 -L /mysql_backup.log
crond -l 8 -L /misql_backup.log &

echo "Listening on crond logfile..."

tail -n +1 -f logfile

echo "Script ends"