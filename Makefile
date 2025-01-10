.PHONY: up down help backup update clean version

##
## Docker Inffra
## 

# Config
SERVICES_DIR=./services
SERVICES=$(shell find $(SERVICES_DIR) -readable -type f -maxdepth 3 -name "docker-compose.yml" 2>/dev/null)
ORIGINAL_DIR=$(shell pwd)
HOSTNAME?=$(shell hostname)

## -
BACKUP_DATE=$(shell date +"%Y%m%d%H%M%S")
BACKUP_PATH=../
BACKUP_FILE=$(BACKUP_PATH)backup_$(HOSTNAME)_$(BACKUP_DATE).tar.lz4

# Config (override)
ifneq (,$(wildcard ./.env))
	include ./.env
endif

define dockerCompose
	@for service in $(SERVICES); do \
		if [ -e "$$(dirname $$service)/enabled" ]; then \
			echo "Service: $$service"; \
			cd $$(dirname $$service) && docker compose $(1); \
			cd $(ORIGINAL_DIR); \
		fi; \
	done
endef

define rootCheck
	@if [ $$(uname -s) = "Linux" ] && ! [ $$(id -u) = 0 ]; then \
		echo "You are not root, run this target as root please"; \
		exit 1; \
	fi
endef

# Targets

## Show help
help:
	@awk '/^## / \
		{ if (c) {print c}; c=substr($$0, 4); next } \
		c && /(^[[:alpha:]][[:alnum:]_-]+:)/ \
		{print $$1, "\t", c; c=0} \
		END { print c }' $(MAKEFILE_LIST)

## Show tools versions
version: 
	@docker -v

## Update infra and enabled services
pull: 
	@git pull
	@git submodule update --init --recursive
	$(call dockerCompose, pull)

## Remove unused images
clean: 
	@docker image prune -a -f

## Start enabled services
up:
	$(call dockerCompose, up -d);
	
## Stop enabled services
down: 
	$(call dockerCompose, down)
	
## Stops the infra, run a Backup, then restart it
backup: 
	$(call rootCheck)
	@echo "Shutting down infra..."
	@make down
	@echo "Creating backup file: $(BACKUP_FILE)"
	@find ./ -type f -name "nobackup" -exec dirname {} \; > ./excluded_dirs.txt
	@tar cf - --exclude-from=./excluded_dirs.txt $(SERVICES_DIR) | lz4 > $(BACKUP_FILE)
	@rm ./excluded_dirs.txt
	@echo "Starting infra..."
	@make up
	@echo "Backup complete!"

