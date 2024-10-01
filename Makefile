.PHONY: up down help backup update clean version

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

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

version: ## Show tools versions
	@docker -v

update: ## Update enabled services
	@git pull
	@git submodule update --init --recursive
	$(call dockerCompose, pull)

clean: ## Remove unused images
	@docker image prune -a -f

up: ## Start enabled services
	$(call dockerCompose, up -d);
	
down: ## Stop enabled services
	$(call dockerCompose, down)
	
backup: ## Backup
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

