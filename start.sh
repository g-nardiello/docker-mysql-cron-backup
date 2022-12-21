function final_backup {
    DATE=$(date +%Y%m%d%H%M)
    echo "=> Requested last backup at $(date "+%Y-%m-%d %H:%M:%S")"
    exec /backup
    exit 0
}

if ! [ -z "${EXIT_BACKUP}" ]; then
  echo "=> Listening on container shutdown to make last backup"
  trap final_backup SIGHUP SIGINT SIGTERM
fi

exec dockerize -wait tcp://${MYSQL_HOST}:${MYSQL_PORT} -timeout ${TIMEOUT} /run.sh