if ! [ -z "${EXIT_BACKUP}" ]; then
  echo "=> Listening on container shutdown to make last backup"
  trap "/backup.sh" SIGHUP SIGINT SIGTERM
fi

dockerize -wait tcp://${MYSQL_HOST}:${MYSQL_PORT} -timeout ${TIMEOUT} /run.sh

while : ; do sleep 1 ; done