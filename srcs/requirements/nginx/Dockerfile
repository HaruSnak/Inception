FROM debian:bullseye

# Install nginx and openssl
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create directory for SSL certificates and generate self-signed certificate
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42School/OU=shmoreno/CN=shmoreno.42.fr"

# Copy nginx configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /entrypoint.sh

# Make entrypoint executable and set permissions
RUN chmod +x /entrypoint.sh && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Expose port 443
EXPOSE 443

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
