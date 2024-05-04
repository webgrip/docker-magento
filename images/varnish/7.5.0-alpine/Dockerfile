# Dockerfile
FROM alpine:7.5.0

# Install Varnish using Alpine's package manager without any cache
RUN apk add --no-cache varnish

# Copy Varnish configuration from the project directory
COPY ../default.vcl /etc/varnish/default.vcl

# Expose port 6081 for Varnish HTTP traffic
EXPOSE 6081

# Start Varnish daemon with specified storage, configuration file, and run it in foreground
CMD ["varnishd", "-F", "-f", "/etc/varnish/default.vcl", "-s", "malloc,256M"]
