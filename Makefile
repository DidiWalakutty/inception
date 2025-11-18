NAME := inception

WORDPRESS_PATH := /home/$(USER)/data/wordpress
MARIADB_PATH := /home/$(USER)/data/mariadb
DOCKER_COMPOSE := src/docker-compose.yml

all: prepare build up		# build + start services

prepare:			# create data volume directories 
	@mkdir -p ${WORDPRESS_PATH}
	@mkdir -p ${MARIADB_PATH}
	@echo "--- Created data volume directories... ---"

build:				# build all containers
	@docker-compose -f ${DOCKER_COMPOSE} build
	@echo "--- Docker images were built... ---"

up:					# start all containers
	@docker-compose -f ${DOCKER_COMPOSE} up -d
	@echo "--- Docker services started ---"

down:				# stop + remove all project containers
	@docker-compose -f ${DOCKER_COMPOSE} down
	@echo "--- Docker services stopped + removed ---"

clean: down			# + remove all exited containers globally.
	@docker rm $(docker ps --filter status=exited -q) 2>/dev/null || true
	@echo "--- Removed all exited containers ---"

fclean: down		# also prunes containers/images/networks
	@docker system prune -af
	@echo "--- Removed images, networks etc. ---"

deepclean: fclean	# above + remove + all data + volumes
	@docker-compose -f ${DOCKER_COMPOSE} down --volumes
	@sudo rm -rf ${WORDPRESS_PATH}
	@sudo rm -rf ${MARIADB_PATH}
	@echo "--- Full reset: volumes + data directories were removed ---"

re:	fclean all		# full rebuild

.PHONY: all prepare build up down clean fclean deepclean re status logs