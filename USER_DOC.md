#USER_DOC

## Overview
This project provides a fully containerized WordPress website using:
- **MariaDB** - stores all WordPress data (pages, users, themes, and site settings). It keeps anything WordPress needs between page loads, and WordPress queries it to display and manage the site. Without it, the site couldn’t save or retrieve information. MariaDB is a fork of MySQL, an open-source database that uses SQL (Structured Query Language) to manage data. 
- **WordPress** - what the site does. It handles website content (pages/posts, menuts, themes etc). It processes PHP (server programming language used to generate dynamic sites) scripts via PHP-FPM (the process manager that executes PHP code) and queries the database to display and manage content.
- **NGINX** - how the site is delivered. It's a web server that delivers the website to users. It serves static files like images and styles, and sends PHP requests to WordPress to generate pages. It also handles HTTPS to keep the site secure.

When a user visits the website, NGINX receives the request, forwards PHP requests to WordPress, which queries MariaDB for data and generates the page that Nginx sends back to the user.

---

## Starting and Stopping the Project
Please check the Makefile for all possibilities.

### Start the project
From the project root, run: `make all`
This will:
- Prepare – create the necessary data directories for WordPress and MariaDB.
- Build – build all Docker images for the project.
- Up – start all services (NGINX, WordPress, MariaDB).

### Stop the project
There's several options to stop the project:

- To stop and remove all containers, run: `make down`
This will stop all containers safely, removes containers, but keeps your data in the volumes
- To clean exited containers, run: `make clean`
- To remove containers, images and networks, run: `make fclean`
- To fully reset, including all data and volumes, run: `make deepclean`

---

## Access the Website and Admin Panel

- Website: https://diwalaku.42.fr or https://localost
- WordPress Admin Panel: either use the icon, or go to https://diwalaku.42.fr/wp-admin

Please use the `.env` file and `secrets/` to access the information to log in.

--- 

## Locating and Managing Credentials

Both the `.env` file and `secrets/` directory are stored in `cd ~/.local/`. 
You can open this by entering the command `code .`.

--- 

## Checking Services and Other things

You can verify that all services are running and mandatory things have been set up correctly by using the following commands:

- List running containers: `docker ps`
- List all Docker images: `docker images`
- List all Docker volumes: `docker volumes ls`
- List all Networks: `docker volume ls`
- List all bind-mounted directories/volumes: `ls -l /home/didi/data/`
- To check Docker version: `docker --version`
- To check Docker status: `sudo systemctl status docker`
- Check container logs: `docker compose logs -f`
- Ensure NGINX can only be accessed by port 443: `wget http://diwalaku.42.fr` or `curl -v http://diwalaku.42.fr`
- Ensure that a SSL/TLS certificate is used: `openssl s_client -connect diwalaku.42.fr:443 </dev/null` or `curl -I https://diwalaku.42.fr`
- Ensure the use of a TLS v1.2 or v1.3: `openssl s_client -connect diwalaku.42.fr:443 -tls1_2` or `openssl s_client -connect diwalaku.42.fr:443 -tls1_3`
- Reboot VM: `sude reboot`

## Verify that MariaDB isn't empty
1. log into your mariadb container: `docker exec -it mariadb bash`
2. login using: `mysql -u root -p`
3. use the mariadb password you put in /secret 
4. Then we need to demonstrate that the database isn’t empty:

        - SHOW DATABASES;
        - USE wordpress_db;
        - SHOW TABLES;
        - SELECT * FROM wp_users;

This will show our database isn’t empty.
Use `exit;` to leave the container.

## Show .key and .crt in NGINX + port 443
1. Log into your NGINX container: `docker exec -it nginx bash`
2. In here, we can show the nginx .key and .crt in /etc/nginx/ssl/, where we can cat both.
3. I saved my .key and .crt in my ~/.local directory, so i can also open it here and show that it’s been regenerated.
Use `exit;` to leave the container.

### Port 443
To show the NGINX container is only bound to port 443: `ss -tlnp | grep nginx`
Use `exit;` to leave the container.
