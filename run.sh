#!/bin/bash
tail -F /mysql_backup.log &

if [ "${INIT_BACKUP:-0}" -gt "0" ]; then
  echo "=> Create a backup on the startup"
  /backup.sh
elif [ -n "${INIT_RESTORE_LATEST}" ]; then
  echo "=> Restore latest backup"
  until nc -z "$MYSQL_HOST" "$MYSQL_PORT"
  do
      echo "waiting database container..."
      sleep 1
  done
  # The [^l] is needed to exclude the latest backup file, and sort only data-tagged backups
  find /backup -maxdepth 1 -name '[^l]*.sql.gz' | sort | tail -1 | xargs /restore.sh
fi

echo "${CRON_TIME} /backup.sh >> /mysql_backup.log 2>&1" > /tmp/crontab.conf
crontab /tmp/crontab.conf
echo "=> Running cron task manager in foreground"
exec crond -f -l 8 -L /mysql_backup.log
