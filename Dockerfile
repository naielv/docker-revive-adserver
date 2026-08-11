FROM alpine:3.22

WORKDIR /var/www/html

RUN apk --update upgrade \
    && apk update \
    && apk add curl ca-certificates \
    && update-ca-certificates --fresh \
    && apk add openssl

RUN apk --update add \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
        nginx \
        gzip \
        pcre \
        php84 \
        php84-curl \
        php84-fpm \
        php84-gd \
        php84-mbstring \
        php84-mysqli \
        php84-mysqlnd \
        php84-opcache \
        php84-pdo \
        php84-pdo_mysql \
        php84-xml \
        php84-openssl \
        php84-zlib \
        php84-pecl-memcached \
        php84-json \
    && rm -rf /var/cache/apk/*

RUN wget -qO- https://download.revive-adserver.com/revive-adserver-6.0.8.tar.gz | tar xz --strip 1 \
    && chown -cfR nobody:nobody . \
    && rm -rf /var/cache/apk/* \
    && echo -e "#!/bin/sh\ncurl -s -o /dev/null http://127.0.0.1/maintenance.php" > /etc/periodic/daily/maintenance \
    && chmod +x /etc/periodic/daily/maintenance

COPY nginx/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /run/nginx

EXPOSE 80

CMD crond -l 2 -b && php-fpm84 && nginx -g "daemon off;"
