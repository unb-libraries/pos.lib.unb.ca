#!/usr/bin/env sh
# Check if this is a new deployment. If so, install.
if [ ! -f /tmp/OSPOS_DB_LIVE ];
then
  # Create Database.
  mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOSTNAME} -P ${MYSQL_PORT} -e "DROP DATABASE IF EXISTS ${MYSQL_DATABASE}; CREATE DATABASE ${MYSQL_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci; CREATE USER '${MYSQL_USERNAME}'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USERNAME}'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; FLUSH PRIVILEGES;"
  mysql -uroot -p${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOSTNAME} -P ${MYSQL_PORT} ${MYSQL_DATABASE} < /app/html/database/database.sql
fi
