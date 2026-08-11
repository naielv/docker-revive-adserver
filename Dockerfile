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
        php84-intl \
        php84-mbstring \
        php84-mysqli \
        php84-mysqlnd \
        php84-opcache \
        php84-pdo \
        php84-pdo_mysql \
        php84-tokenizer \
        php84-xml \
        php84-openssl \
        php84-zip \
        php84-zlib \
        php84-pecl-memcached \
        php84-json \
    && rm -rf /var/cache/apk/*

RUN wget -qO- https://download.revive-adserver.com/revive-adserver-6.0.8.tar.gz | tar xz --strip 1 \
    && chown -cfR nobody:nobody . \
    && rm -rf /var/cache/apk/* \
    && echo -e "#!/bin/sh\ncurl -s -o /dev/null http://127.0.0.1/maintenance.php" > /etc/periodic/daily/maintenance \
    && chmod +x /etc/periodic/daily/maintenance

RUN printf '%s\n' \
    'allow_url_fopen = On' \
    'file_uploads = On' \
    'max_execution_time = 300' \
    'max_input_vars = 5000' \
    'memory_limit = 256M' \
    'post_max_size = 64M' \
    'session.auto_start = Off' \
    'upload_max_filesize = 64M' \
    > /etc/php84/conf.d/99-revive.ini

COPY nginx/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /run/nginx

EXPOSE 80

CMD if ! find /var/www/html/var -maxdepth 1 \( -name "*.conf.php" -o -name "*.conf.ini" \) -print -quit | grep -q .; then \
        touch /var/www/html/var/UPGRADE; \
    fi && \
    crond -l 2 -b && php-fpm84 && nginx -g "daemon off;"
