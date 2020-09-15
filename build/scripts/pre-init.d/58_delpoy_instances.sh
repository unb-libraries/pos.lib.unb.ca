#!/usr/bin/env bash
set -e

DOMAINS="hil hwkc"
CONF=""

if [[ "$DEPLOY_ENV" != "local" ]]; then
  read -ra DOMAIN <<<"$DOMAINS"
  for i in "${DOMAIN[@]}"; do
    echo "Deploying instance for \"${i}\"..."

    cp -r /tmp/ospos/* "/app/$i/"
    cp /app-config/database.php "/app/$i/application/config/"
    sed -i "s|MYSQL_DATABASE|MYSQL_DATABASE_${i^^}|g" "/app/$i/application/config/database.php"
    if [[ -d "/app-config/$i/" ]]
    then
      cp -r "/app-config/$i/" "/app/"
    fi
    NGINXDOM="$i"
    if [[ "$DEPLOY_ENV" = "dev" ]]; then
      NGINXDOM="dev-$i"
      sed -i "s|https://${i}-pos|https://${NGINXDOM}-pos|g" /app/html/public/index.html
    fi
    CONFNEW=$(cat <<EOF

  server {
    listen  80;
    charset utf-8;
    server_name $NGINXDOM-pos.lib.unb.ca;

    root /app/$i/public;
    index index.html index.htm index.php;

    access_log NGINX_LOG_FILE main;
    error_log NGINX_ERROR_LOG_FILE warn;

    location / {
      try_files \$uri \$uri/ /index.html /index.htm /index.php?\$query_string /index.php;
    }

    location = /favicon.ico { log_not_found off; access_log off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    # pass the PHP scripts to php-fpm
    location ~ \.php$ {
      fastcgi_split_path_info ^(.+\.php)(/.+)$;
      fastcgi_pass unix:/var/run/php/php-fpm7.sock;
      fastcgi_index index.php;
      fastcgi_param APPLICATION_ENV $DEPLOY_ENV;
      fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
      include fastcgi_params;
    }

    # Deny . (dot) file access
    location ~ (^|/)\. {
      return 403;
    }
  }

EOF
    )

    CONF+="$CONFNEW"

    DBVAR="MYSQL_DATABASE_${i^^}"
    sed -i "s|MYSQL_HOSTNAME|$MYSQL_HOSTNAME|g" "/app/$i/application/config/database.php"
    sed -i "s|$DBVAR|${!DBVAR}|g" "/app/$i/application/config/database.php"
    sed -i "s|MYSQL_USERNAME|$MYSQL_USERNAME|g" "/app/$i/application/config/database.php"
    sed -i "s|MYSQL_PASSWORD|$MYSQL_PASSWORD|g" "/app/$i/application/config/database.php"

    # Set 24-hour-long session expiry
    echo "\$config['sess_expiration'] = 86400;" >> "/app/$i/application/config/config.php"

    echo "Setting HTTPS for non-local deployment..."
    echo "\$config['base_url'] = str_replace('http:', 'https:', \$config['base_url']);" >> "/app/$i/application/config/config.php"
  done

else
  echo 'Deploying a single local instance...'
  rm /app/html/public/index.html
  cp -r /tmp/ospos/* /app/html/
  cp /app-config/database.php /app/html/application/config/

  sed -i "s|MYSQL_HOSTNAME|$MYSQL_HOSTNAME|g" "/app/html/application/config/database.php"
  sed -i "s|MYSQL_DATABASE|$MYSQL_DATABASE|g" "/app/html/application/config/database.php"
  sed -i "s|MYSQL_USERNAME|$MYSQL_USERNAME|g" "/app/html/application/config/database.php"
  sed -i "s|MYSQL_PASSWORD|$MYSQL_PASSWORD|g" "/app/html/application/config/database.php"
fi

echo "$CONF
}" >> /etc/nginx/conf.d/app.conf
