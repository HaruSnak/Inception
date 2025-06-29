FROM debian:bullseye

# Install MariaDB server
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/entrypoint.sh /entrypoint.sh

# Make entrypoint executable
RUN chmod +x /entrypoint.sh

# Create mysql directories
RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 755 /var/run/mysqld

# Set permissions for mysql data directory
RUN chown -R mysql:mysql /var/lib/mysql

# Expose port 3306
EXPOSE 3306

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Start MariaDB
CMD ["mysqld_safe"]
