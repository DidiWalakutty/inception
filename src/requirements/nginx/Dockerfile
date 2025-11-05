# Dockerfile to create the NGINX image.

FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y nginx openssl curl && \
    rm -rf /var/lib/apt/lists/*
# Update package lists, install required packages, -y for auto yes answer, then clean apt cache
	# nginx: the web server
	# openssl: to generate self-signed TLS certs
	# curl: useful for healthchecks
# cleans up th epackage index cache that's downloaded during apt-get update.
# reduces the final image size by removing unnec. metadata.

COPY conf/default.conf /etc/nginx/conf.d/default.conf
# copies the nginx config into the container.
# adds a custom server block to extend nginx's default configuration

COPY tools/nginx.crt /etc/ssl/private/nginx.crt
COPY tools/nginx.key /etc/ssl/private/nginx.key
# Copy SSL certificate and key for HTTPS
# These are generated beforehand and mounted into the container image

EXPOSE 443
# declares that the container listens on port 443 (HTTPS)

CMD ["nginx", "-g", "daemon off;"]
# runs nginx in the foreground so the container stays alive
# Run NGINX in the foreground (required for Docker)

