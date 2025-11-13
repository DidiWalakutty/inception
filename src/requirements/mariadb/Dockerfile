# This Dockerfile builds the MariaDB container.

FROM debian:bullseye

# Install MariaDB server + client, clean up image size
RUN apt update && apt install -y mariadb-server mariadb-client && \
	apt autoremove -y && apt autoclean

# Copy custom configuration	
COPY ./conf/my.cnf /etc/mysql/my.cnf

# Setup directories + permission
RUN mkdir -p /var/run/mysqld /var/lib/mysql && \
	chown -R mysql:mysql /var/run/mysqld /var/lib/mysql && \
	chmod 777 /var/run/mysqld

# Bootstrap script for database setup + creating user 
COPY ./tools/db_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/db_setup.sh

# Expose default MariaDB port
EXPOSE 3306

# Set default command
CMD ["/usr/local/bin/db_setup.sh"]