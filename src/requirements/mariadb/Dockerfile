FROM debian:bookworm

RUN apt update && apt install -y mariadb-server mariadb-client && \
	apt autoremove -y && apt autoclean

# Copies custom MariaDB my.conf into container. Overwrites default config
COPY ./conf/my.cnf /etc/mysql/my.cnf

# Where MariaDB will store its data, runs as mysql user
RUN mkdir -p /var/run/mysqld /var/lib/mysql && \
	chown -R mysql:mysql /var/run/mysqld /var/lib/mysql && \
	chmod 777 /var/run/mysqld

# Bootstrap script and make it executable
COPY ./tools/db_setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/db_setup.sh

# Expose default MariaDB port
EXPOSE 3306

# Set default command to execute the script
CMD ["/usr/local/bin/db_setup.sh"]