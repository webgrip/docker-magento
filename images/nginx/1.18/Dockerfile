# Use a specific version of the base image for both builder and production
FROM nginx:1.18-alpine AS base
LABEL maintainer="Ryan Grippeling <ryan@webgrip.com>"

ENV APP_USER=app \
    APP_GROUP=app \
    APP_UID=1000 \
    APP_GID=1000

# Creating user and group early to avoid unnecessary layers later
RUN addgroup -g "${APP_GID}" "${APP_GROUP}" && \
    adduser -G "${APP_GROUP}" -u "${APP_UID}" -h /var/www -s /bin/bash -S "${APP_USER}" && \
    mkdir -p /etc/nginx/certs /etc/nginx/html /var/www/html /sock /var/run && \
    touch /var/run/nginx.pid && \
    chown -R "${APP_USER}:${APP_GROUP}" /etc/nginx /var/www /var/cache/nginx /var/run/nginx.pid /sock

# Base openssl and certificates setup (for SSL/TLS)
RUN apk add --no-cache openssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/certs/nginx.key -out /etc/nginx/certs/nginx.crt -subj "/C=US/ST=Overijssel/L=Deventer/O=WebGrip/OU=Unit/CN=webgrip.nl" && \
    chown "${APP_USER}:${APP_GROUP}" /etc/nginx/certs/nginx.key /etc/nginx/certs/nginx.crt


# Production-ready configuration
FROM base AS production
COPY ./conf/nginx.production.conf /etc/nginx/nginx.conf
COPY ./conf/default.production.conf /etc/nginx/conf.d/default.conf
EXPOSE 443
USER "${APP_USER}":"${APP_GROUP}"
VOLUME /var/www
WORKDIR /var/www/html

# Development configuration
FROM base AS development
# Add tools for development
RUN apk add --no-cache curl ca-certificates

# mkcert installation stage
FROM development AS mkcert-installer
RUN apk add --no-cache nss-tools && \
    wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 -O /usr/local/bin/mkcert && \
    chmod +x /usr/local/bin/mkcert && \
    mkdir -p /usr/local/share/ca-certificates/mkcert && \
    mkcert -install

# Final development stage
FROM development
COPY --from=mkcert-installer /usr/local/bin/mkcert /usr/local/bin/mkcert
COPY --from=mkcert-installer /usr/local/share/ca-certificates/mkcert /usr/local/share/ca-certificates/mkcert

# Copy development-specific Nginx configuration
COPY ./conf/nginx.development.conf /etc/nginx/nginx.conf
COPY ./conf/default.development.conf /etc/nginx/conf.d/default.conf

EXPOSE 443
USER "${APP_USER}":"${APP_GROUP}"
VOLUME /var/www
WORKDIR /var/www/html

CMD ["nginx", "-g", "daemon off;"]
