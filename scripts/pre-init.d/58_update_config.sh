#!/usr/bin/env sh
sed -i "s|MYSQL_HOSTNAME|$MYSQL_HOSTNAME|g" /app/html/application/config/database.php
sed -i "s|MYSQL_DATABASE|$MYSQL_DATABASE|g" /app/html/application/config/database.php
sed -i "s|MYSQL_USERNAME|$MYSQL_USERNAME|g" /app/html/application/config/database.php
sed -i "s|MYSQL_PASSWORD|$MYSQL_PASSWORD|g" /app/html/application/config/database.php

if [ "$DEPLOY_ENV" != "local" ]; then
  echo "Setting HTTPS for non-local deployment..."
  echo "\$config['base_url'] = str_replace('http:', 'https:', \$config['base_url']);" >> /app/html/application/config/config.php
fi
