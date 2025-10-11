FROM debian:bullseye

# Install MariaDB server
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/entrypoint.sh /entrypoint.sh

# Make entrypoint executable, create directories and set permissions
RUN chmod +x /entrypoint.sh && \
    mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql && \
    chmod 755 /var/run/mysqld

# Expose port 3306
EXPOSE 3306

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Start MariaDB
CMD ["mysqld_safe"]
