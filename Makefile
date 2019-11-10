# Si besoin à remplacer le nom de l'utilisateur docker final
DOCKER_USER=jeromeklam

# Map de port, si le 3306 est déjà pris
PORT:=127.0.0.1:8807

# Nom du container
NAME:=u18_mariadb

# Chemin courant = real_path
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# Id, ... de docker
RUNNING:=$(shell docker ps | grep $(NAME) | cut -f 1 -d ' ')
ALL:=$(shell docker ps -a | grep $(NAME) | cut -f 1 -d ' ')

# Options de la ligne de commande
DOCKER_RUN_COMMON=--name="$(NAME)" -p $(PORT):3306 -e USER=admin -e PASS=jvs-m $(DOCKER_USER)/$(NAME)

# Par défaut le build
all: build

# Compilation de l'image
build: clean
	mkdir -p $(ROOT_DIR)/docker-logs
	mkdir -p $(ROOT_DIR)/docker-db/mariadb
	docker build -t="$(DOCKER_USER)/$(NAME)" .

# Démarrage du container
run: clean
	mkdir -p $(ROOT_DIR)/docker-logs
	mkdir -p $(ROOT_DIR)/docker-db/mariadb
	docker run -d $(DOCKER_RUN_COMMON)

# Arrêt du container
stop: clean

# Démarrage d'un bash sur le container
bash: clean
	mkdir -p $(ROOT_DIR)/docker-logs
	mkdir -p $(ROOT_DIR)/docker-db/mariadb
	docker run -t -i $(DOCKER_RUN_COMMON) /bin/bash

# Démarrage d'un bash sur le container
wbash: clean
	mkdir -p $(ROOT_DIR)/docker-logs
	mkdir -p $(ROOT_DIR)/docker-db/mariadb
	winpty docker run -t -i $(DOCKER_RUN_COMMON) /bin/bash

# Supprime les containers existants
clean:
ifneq ($(strip $(RUNNING)),)
	docker stop $(RUNNING)
endif
ifneq ($(strip $(ALL)),)
	docker rm $(ALL)
endif

# Nettoyage complet !!!
deepclean: clean
	rm -rf $(ROOT_DIR)/docker-logs
	rm -rf $(ROOT_DIR)/docker-db
