

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::   #
#    Makefile                                           :+:      :+:    :+:   #
#                                                     +:+ +:+         +:+     #
#    By: shmoreno <shmoreno@student.42.fr>          +#+  +:+       +#+        #
#                                                 +#+#+#+#+#+   +#+           #
#    Created: 2025/06/29 00:00:00 by shmoreno          #+#    #+#             #
#    Updated: 2025/06/29 00:00:00 by shmoreno         ###   ########.fr       #
#                                                                              #
# **************************************************************************** #

DOCKER_COMPOSE = docker compose
DOCKER_COMPOSE_FILE = ./srcs/docker-compose.yml
DATA_PATH = /home/shmoreno/data

.PHONY: all build up down clean fclean re logs

all: build up

build:
	@echo "Building Docker images..."
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/mariadb
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) build

up:
	@echo "Starting containers..."
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up -d

down:
	@echo "Stopping containers..."
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) down

clean: down
	@echo "Cleaning up containers and images..."
	docker system prune -af

fclean: clean
	@echo "Full cleanup including volumes..."
	docker volume prune -f
	@sudo rm -rf $(DATA_PATH)

re: fclean all

logs:
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) logs -f

status:
	$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) ps
