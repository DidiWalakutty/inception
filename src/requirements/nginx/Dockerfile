# Dockerfile to create the NGINX image.

FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y nginx openssl curl && \
    rm -rf /var/lib/apt/lists/*
# checks for latest versions of repositories.
# installs required packages (-y is automatically answer yes to any prompts)
	# nginx: the web server
	# openssl: to generate self-signed TLS certs
	# curl: useful for healthchecks
# cleans up th epackage index cache that's downloaded during apt-get update.
# reduces the final image size by removing unnec. metadata.

COPY config/nginx.conf /etc/nginx/nginx.conf.d/nginx.conf
# copies the nginx config into the container.
# adds a custom server block to extend nginx's default configuration

COPY tools/ssl/nginx.crt /etc/ssl/private/nginx.crt
COPY tools/ssl/nginx.key /etc/ssl/private/nginx.key
# copies SSL certificate and private key into the container for HTTPS

EXPOSE 443
# declares that the container listens on port 443 (HTTPS)

CMD ["nginx", "-g", "daemon off;"]
# runs nginx in the foreground so the container stays alive