FROM ghcr.io/unb-libraries/nginx-php:3.18.x

ARG DOWNLOAD_URL=https://github.com/opensourcepos/opensourcepos/releases/download/3.3.9/opensourcepos.3.3.9.c00ff2.zip
ENV APP_WEBROOT /app/html/public
ENV SITE_URI pos.lib.unb.ca

COPY ./build /build

# Install required packages, libraries.
RUN apk --no-cache add bash php81-mysqli php81-session php81-gd \
   php81-bcmath php81-intl php81-openssl php81-dom php81-curl \
   php81-ctype php81-mbstring php81-fileinfo php81-simplexml \
   php81-xmlreader php81-xmlwriter php81-zip mysql-client unzip && \
   mkdir /tmp/ospos && cd /tmp/ospos && \
   curl -LO ${DOWNLOAD_URL} && unzip -q *.zip && rm *.zip && \
#   patch -p1 < /build/patches/credit-payment-types.patch && \
#   patch -p1 < /build/patches/detailed-sales-report-time.patch && \
   find /build/app-config -name composer.json|xargs -n 1 dirname|xargs -n 1 composer install --prefer-dist -d && \
   mv /build/nginx/app.conf "$NGINX_APP_CONF_FILE" && \
   ${RSYNC_MOVE} /build/scripts/container/ /scripts/
# && \
#   mv /build/www/index.html /app/html/public/index.html

# Volumes
VOLUME /app/hil/public/uploads
VOLUME /app/hwkc/public/uploads
VOLUME /app/sci/public/uploads
VOLUME /app/eng/public/uploads

LABEL ca.unb.lib.generator="ospos" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.description="pos.lib.unb.ca provides Point-Of-Sale transactions at UNB Libraries." \
  org.label-schema.name="ospos" \
  org.label-schema.url="https://github.com/unb-libraries/pos.lib.unb.ca" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/unb-libraries/pos.lib.unb.ca" \
  org.label-schema.version=$VERSION \
  org.opencontainers.image.authors="UNB Libraries <libsupport@unb.ca>" \
  org.opencontainers.image.source="https://github.com/unb-libraries/pos.lib.unb.ca"
