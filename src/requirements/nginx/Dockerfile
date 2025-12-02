# Dockerfile to create the NGINX image.

FROM debian:bullseye

RUN apt update && apt install -y nginx openssl curl && \
    apt autoremove -y && apt autoclean

# Update package lists, install required packages, -y for auto yes answer, then clean apt cache
	# nginx: the web server
	# openssl: to generate self-signed TLS certs
	# curl: useful for healthchecks
# cleans up the package index cache that's downloaded during apt-get update.
# reduces the final image size by removing unnec. metadata.

# Create a directory in the NGINX container where we store the key and crt.
RUN mkdir -p /etc/nginx/ssl && \
	chmod 700 /etc/nginx/ssl

COPY conf/default.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/sites-enabled/default
# copies the nginx config into the container.
# adds a custom server block to extend nginx's default configuration

# generates a new .key and .crt with every build.
# writes those into the container
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=NL/ST=IDF/L=Amsterdam/O=42/OU=42/CN=diwalaku.42.fr"

EXPOSE 443
# declares that the container listens on port 443 (HTTPS)

CMD ["nginx", "-g", "daemon off;"]
# run nginx in the foreground (daemon off) so the container stays alive
# required in Docker: if the main process exits, the container stops

