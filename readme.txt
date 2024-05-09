Docker Infra
============

Requirements:
- Docker

Services:

To enable a docker service, create an empty file named "enabled" in the service folder. 
To prevent backups, create a "nobackup" file
Then, only run "make up". To override a config. you can use a .env file 
or "docker-compose.override.yml"

Config:

To override some config, create a .env file.
- BACKUP_PATH=./

Commands:

- make update
- make up
- make down
- sudo make backup