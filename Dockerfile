FROM unblibraries/nginx-php:alpine-php7
MAINTAINER Brian Cassidy <libsystems_at_unb.ca>

ARG DOWNLOAD_URL=https://github.com/opensourcepos/opensourcepos/releases/download/3.3.0/opensourcepos.20190929181753.3.3.0.0b9a76.zip
ENV APP_WEBROOT /app/html/public
ENV SITE_URI pos.lib.unb.ca

COPY ./scripts /scripts
COPY ./patches /patches
COPY ./package-conf /package-conf


# Install required packages, libraries.
RUN apk --no-cache add php7-mysqli php7-session php7-gd \
   php7-bcmath php7-intl php7-openssl php7-dom php7-curl \
   php7-ctype php7-mbstring php7-fileinfo php7-simplexml \
   php7-xmlreader php7-xmlwriter php7-zip mysql-client unzip rsyslog && \
   /scripts/initRsyslog.sh && \
   /scripts/installNewRelic.sh && \
   cd /app/html && \
   curl -LO ${DOWNLOAD_URL} && unzip *.zip && rm *.zip && \
   patch -p1 < /patches/credit-payment-types.patch && \
   patch -p1 < /patches/detailed-sales-report-time.patch && \
   mv /package-conf/nginx/app.conf /etc/nginx/conf.d/app.conf && \
   mkdir -p /etc/rsyslog.d && \
   mv /package-conf/rsyslog/21-logzio-nginx.conf /etc/rsyslog.d/21-logzio-nginx.conf

COPY ./config/database.php /app/html/application/config/database.php
COPY ./reporting /app/html/public/reporting

RUN cd /app/html/public/reporting && composer install --prefer-dist

# Volumes
VOLUME /app/html/public/uploads

# Metadata
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL ca.unb.lib.generator="ospos" \
      com.microscaling.docker.dockerfile="/Dockerfile" \
      com.microscaling.license="MIT" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.description="pos.lib.unb.ca provides Point-Of-Sale transactions at UNB Libraries." \
      org.label-schema.name="pos.lib.unb.ca" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.url="https://pos.lib.unb.ca" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/unb-libraries/pos.lib.unb.ca" \
      org.label-schema.vendor="University of New Brunswick Libraries" \
      org.label-schema.version=$VERSION
