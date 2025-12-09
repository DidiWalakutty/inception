#DEV_DOC

## Overview
This project sets up a complete WordPress using Docker.
It includes three main services:

- **MariaDB** - stores all WordPress data in a persistent volume.
- **WordPress** - handles website content and processes PHP scripts via PHP-FPM to display the site to the user.
- **NGINX** - how the site is delivered. It serves static files like images and styles and sends PHP requests to WordPress to generate pages. Also handles HTTPS to keep everything secure.

Each service runs in its own container and communicates through an internal Docker network.
This document explains how a developer can set up the environment from scratch, configure the required files/directories, manage containers and volumes, and build and run the project.

## Set up the environment from scratch

### The VM setup
- You must first create a VM through the Oracle Virtual Box.
- You create a new VM in the folder `~/sgoinfre` and won't select an ISO image. You'll download this from the official Debian website.
- Choose your type (Linux) and install the correct Debian/Alpine version.
- Make sure you have enough memory and processors available. I chose 4096mg and 8 processors.
- I chose a disk size of 20GB to make sure I have enough space for my project.
- Continu setting up your VM.
- Install your system updates and required packages (Docker, Docker Compose, Make etc).

### Install prerequisites
- `apt update && apt upgrade`
- Install the following:
   - Docker
   - Docker Compose
   - Make
   - Openssl
   - Docker engine
   - Docker Daemon
   - WP Cli
   - whatever else you think you need

I also preferred being linked to VSCode on my Host machine to have a better overview of the project.
Make sure remote SSH is installed on VSCode.

I also enabled icons on the VM Desktop.
Because we use a GNOME desktop, it doesn't show these by default, so I enabled them manually: 
- `sudo apt install gnome-shell-extension-desktop-icons-ng -y`
- `gnome-extensions enable ding@rastersoft.com`
- reboot

### Configuration Files
- Create a `docker-compose.yml` file in `src/`.
This file declares the 3 services (MariaDB, WordPress and NGINX) and is wired to our `.env` and `secrets/` setup. It makes sure every services receives exactly what it needs to run and communicate.
- Create `Dockerfiles` for each separate service. It holds the instructions to build a Docker Image.
- Create an `.env` file and store it somewhere your VM can access it. You should never share it online, because it contains sensitive information.
It should contain the location for your NGINX .cert and .key, usernames for your MariaDB, WP admin and User and where it can find the passwords.
- Create a `secrets/` directory that contains .txt files with the passwords for the user.
Same goes here: it's unsafe to share these online, so keep it somewhere the VM can find it.
- I saved the `.env` and `secrets/` in my `/.local/` directory, where it is stored. The `.env` file knows where to find the passwords.


---

## Starting and Stopping the Project
Please check the Makefile for all available options.
This contains all the commands you'll need to start, stop and delete the containers.

To use Docker Compose instead of the Makefile, you can use the following commands: 
- `docker compose -f srcs/docker-compose.yml build` to build the images
- `docker compose -f srcs/docker-compose.yml up -d` to run the containers in the background.


### Building and Launching the project
From the project root, run: `make all`
This will:
- Prepare – create the necessary data directories for WordPress and MariaDB.
- Build – build all Docker images for the project.
- Up – start all services (NGINX, WordPress, MariaDB).

### Launch the project
- 

### Stop the project
There's several options to stop the project:

- To stop and remove all containers, run: `make down`
This will stop all containers safely, removes containers, but keeps your data in the volumes
- To clean exited containers, run: `make clean`
- To remove containers, images and networks, run: `make fclean`
- To fully reset, including all data and volumes, run: `make deepclean`

---

## Commands to manage the containers and volumes

### Containers
- `docker ps` will list your containers.
- `docker logs <container_name>` will give you a log of the container.
- `docker exec -it <container_name> bash` will give you access to the container.
- `docker stop <container_id>` will pause execution, but keeps the container and its data.
- `docker start <container_id>` will start the container.
- `docker restart <container_id>` will restart the container.
- `docker rm <container_id>` will delete the container.
- `docker rm $(docker ps -aq)` will remove all containers (-a = all, -q = just IDs)
- `docker container prune` to remove only stopped containers.

### Volumes
- `docker volume ls` will show you all volumes.
- `docker volume inspect <volume_name>` will give you all information on this volume.
- `docker volume rm <volume_name>` will delete that volume. 

### Network
- `docker network ls` will show you all networks.
- `docker network inspect <network_name>` will give you all information on this network.

---

## Data storage

### Volumes
The MariaDB and WordPress both use persistent storage for their containers.
Docker Containers itself are designed to be short-lived, meaning that any data generated within that container during runtime will be lost once that container has been stopped/removed.
Volumes are used to persist important data outside of the container, allowing you to keep that data even after the container has been deleted or rebooted.
This makes sure you don't need to load everything again all the time, but also that changes will persevere when the container has been stopped.
It'll keep data safe across restarts.

The MariaDB volume contains all databases tables and data.
The WordPress volume contains the site's theme, plugins, uploads, WP config etc.

### Paths
These volumes are stored on the host machine, outside the container's filesystem.
For this project, we had to use this at `/home/login/data`.

You can find the volumes at the following paths:
- MariaDB: `/home/diwalaku/data/mariadb`
- WordPress: `/home/diwalaku/data/wordpress`

