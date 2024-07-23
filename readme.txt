Docker Infra
============

Requirements:
- Docker

Services:

To enable a docker service, create an empty file named "enabled" in the service folder. 
To prevent backups, create a "nobackup" file anywhere.

To start enabled services, run "make up". 
To override a service configuration, create a "docker-compose.override.yml" file with your settings.

Backups:

To set the folder where the backup will be created, create a .env file with:
- BACKUP_PATH=./

Commands:

- make update
- make up
- make down
- sudo make backup
