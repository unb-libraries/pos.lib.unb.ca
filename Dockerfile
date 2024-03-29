FROM ghcr.io/unb-libraries/nginx-php:1.x-7.x
MAINTAINER Brian Cassidy <libsystems_at_unb.ca>

ARG DOWNLOAD_URL=https://github.com/opensourcepos/opensourcepos/releases/download/3.3.3/opensourcepos.20210101114640.3.3.3.8e52bd.zip
ENV APP_WEBROOT /app/html/public
ENV SITE_URI pos.lib.unb.ca

COPY build/scripts /scripts
COPY build/patches /patches
COPY build/package-conf /package-conf
COPY build/app-config /app-config
COPY build/www/index.html /app/html/public/index.html

# Install required packages, libraries.
RUN apk --no-cache add bash php7-mysqli php7-session php7-gd \
   php7-bcmath php7-intl php7-openssl php7-dom php7-curl \
   php7-ctype php7-mbstring php7-fileinfo php7-simplexml \
   php7-xmlreader php7-xmlwriter php7-zip mysql-client unzip && \
   /scripts/installNewRelic.sh && \
   mkdir /tmp/ospos && cd /tmp/ospos && \
   curl -LO ${DOWNLOAD_URL} && unzip -q *.zip && rm *.zip && \
   patch -p1 < /patches/credit-payment-types.patch && \
   patch -p1 < /patches/detailed-sales-report-time.patch && \
   find /app-config -name composer.json|xargs -n 1 dirname|xargs -n 1 composer install --prefer-dist -d && \
   mv /package-conf/nginx/app.conf /etc/nginx/conf.d/app.conf

# Volumes
VOLUME /app/hil/public/uploads
VOLUME /app/hwkc/public/uploads
VOLUME /app/sci/public/uploads
VOLUME /app/eng/public/uploads

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
      org.label-schema.version=$VERSION \
      org.opencontainers.image.source="https://github.com/unb-libraries/pos.lib.unb.ca"
