# Dockerfile
FROM alpine:3.19.1

# Install Varnish using Alpine's package manager without any cache
RUN apk add --no-cache varnish

# Copy Varnish configuration from the project directory
COPY ./default.vcl /etc/varnish/default.vcl

# Expose port 6081 for Varnish HTTP traffic
EXPOSE 6081

# Create a non-root user and switch to it
RUN addgroup -S varnish && adduser -S varnish -G varnish
USER varnish

# Start Varnish daemon with specified storage, configuration file, and run it in foreground
CMD ["varnishd", "-F", "-f", "/etc/varnish/default.vcl", "-s", "malloc,256M", "-p", "default_ttl=3600", "-p", "default_grace=3600", "-a", ":6081", "-n", "/var/cache/varnish"]
