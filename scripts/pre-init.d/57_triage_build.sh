#!/usr/bin/env sh
# Triage the build to determine how to deploy.

# Remove old file markers to eliminate false positives
rm -rf /tmp/OSPOS_DB_LIVE

# Check if the database has tables named *node*. If so, this is likely a live DB.
RESULT=`mysqlshow -h ${MYSQL_HOSTNAME} -P ${MYSQL_PORT} --user=root --password=${MYSQL_ROOT_PASSWORD} ${MYSQL_DATABASE} | grep sales`
if [[ ! -z "$RESULT" ]]; then
  touch /tmp/OSPOS_DB_LIVE
  echo "Triage : Found OSPOS Database."
fi
