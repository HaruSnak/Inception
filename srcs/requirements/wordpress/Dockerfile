FROM debian:bullseye

# Install required packages
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-intl \
    php7.4-mbstring \
    php7.4-soap \
    php7.4-xml \
    php7.4-xmlrpc \
    php7.4-zip \
    wget \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Download WordPress CLI  
RUN wget https://github.com/wp-cli/wp-cli/releases/download/v2.5.0/wp-cli-2.5.0.phar -O wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy configuration files
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /entrypoint.sh

# Create directories, set permissions and make entrypoint executable
RUN mkdir -p /var/www/html/wordpress /run/php && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html && \
    chmod +x /entrypoint.sh

# Expose port 9000
EXPOSE 9000

# Set working directory
WORKDIR /var/www/html/wordpress

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Start php-fpm
CMD ["php-fpm7.4", "-F"]
