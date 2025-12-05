FROM debian:bookworm

# Install NGINX, OpenSSL (certs) and curl (healthchecks)
RUN apt update && apt install -y nginx openssl curl && \
    apt autoremove -y && apt autoclean

RUN mkdir -p /etc/nginx/ssl && \
	chmod 700 /etc/nginx/ssl

# Add custom NGINX config and remove default
COPY conf/default.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/sites-enabled/default

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=NL/ST=IDF/L=Amsterdam/O=42/OU=42/CN=diwalaku.42.fr"

# Expose default HTTPS port
EXPOSE 443

# Start NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]