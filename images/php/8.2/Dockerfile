# Base stage for common setup
FROM php:8.2-fpm-alpine AS base
LABEL maintainer="Ryan Grippeling <ryan@webgrip.com>"

# Set PHP extensions versions via ARG to ensure they're available in all stages
ARG IMAGICK_VERSION=3.7.0
ARG REDIS_VERSION=6.0.2
ARG SSH2_VERSION=1.3.1

# Environment configuration for consistent user setup across stages
ENV APP_USER=app \
    APP_GROUP=app \
    APP_UID=1000 \
    APP_GID=1000

RUN addgroup -g "${APP_GID}" "${APP_GROUP}" && \
    adduser -G "${APP_GROUP}" -u "${APP_UID}" -h /var/www -s /bin/bash -S "${APP_USER}"

# Builder stage to compile and install PHP extensions
FROM base AS builder

# Install packages required for building PHP extensions
#RUN apk --no-cache add autoconf g++ make bash curl libpng-dev libjpeg-turbo-dev libwebp-dev \
#    gettext-dev icu-dev libxslt-dev zlib-dev libzip-dev freetype-dev bzip2-dev \
#    linux-headers oniguruma-dev libsodium-dev openssl-dev pcre-dev \
#    imagemagick imagemagick-dev libssh2 libssh2-dev php-redis#

RUN apk --no-cache add autoconf g++ make bash curl libpng libjpeg-turbo libwebp \
    gettext icu libxslt zlib libzip freetype bzip2 \
    linux-headers oniguruma libsodium openssl pcre \
    imagemagick libssh2 php-redis libbz2 libpng-dev libjpeg-turbo-dev libwebp-dev \
    gettext-dev icu-dev libxslt-dev zlib-dev libzip-dev freetype-dev bzip2-dev \
    linux-headers oniguruma-dev libsodium-dev openssl-dev pcre-dev \
    imagemagick-dev libssh2-dev libintl #libicu libexslt


# Configure PHP extensions to use support for additional libraries
RUN docker-php-ext-configure gd --with-jpeg --with-freetype --with-webp && \
    docker-php-ext-configure intl && \
    docker-php-ext-configure gettext

# Install PHP extensions
RUN docker-php-ext-install -j"$(nproc)" gd intl gettext bcmath bz2 ctype calendar dom exif \
    fileinfo filter mbstring opcache pdo_mysql simplexml soap sockets sodium sysvmsg sysvsem \
    sysvshm xmlwriter xsl zip

# Install and enable PECL extensions
RUN pecl install \
    imagick-${IMAGICK_VERSION} \
    redis-${REDIS_VERSION} \
    ssh2-${SSH2_VERSION} && \
    pecl clear-cache && \
    docker-php-ext-enable imagick redis ssh2

# Deployment stage copies built extensions and binaries to a lean production image
FROM base AS production

# Copy installed PHP extensions from builder stage
COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d

COPY --from=builder /usr/lib/ /usr/lib/

# Set appropriate permissions and ownership
RUN chown -R ${APP_USER}:${APP_GROUP} /usr/local/lib/php/extensions

# Switch to non-root user for security
USER "${APP_USER}:${APP_GROUP}"

# Define volume for application mount and set working directory
VOLUME /var/www
WORKDIR /var/www/html

FROM production as development
USER root:root