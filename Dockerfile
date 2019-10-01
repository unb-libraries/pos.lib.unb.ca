FROM unblibraries/nginx-php:alpine-php7
MAINTAINER Brian Cassidy <libsystems_at_unb.ca>

ARG DOWNLOAD_URL=https://github.com/opensourcepos/opensourcepos/releases/download/3.3.0/opensourcepos.20190929181753.3.3.0.0b9a76.zip 

# Install required packages, libraries.
RUN apk --no-cache add php7-mysqli php7-session php7-gd \
   php7-bcmath php7-intl php7-openssl php7-dom php7-curl \
   php7-mbstring mysql-client unzip

RUN cd /app/html && curl -LO ${DOWNLOAD_URL} && unzip *.zip && rm *.zip

COPY ./scripts /scripts
COPY ./package-conf/nginx/app.conf /etc/nginx/conf.d/app.conf
COPY ./app-config/database.php /app/html/application/config/database.php
