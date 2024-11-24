# Docker Infra

## Requirements

- Docker
- lz4

## Services

### Configuration

Create and fill a `services/` folder with your services. 
Have a look at `service-demo/` for an exemple.

To enable a docker service, just `touch enabled` in the service folder. 
To disable one, just remove the file. You might have to manually stop the service with `docker-compose down`.  

### Start services

To start enabled services, run `make update` then `make up`. 

To override a service configuration, create a `docker-compose.override.yml` file with your settings.
It's also safe to use a `.env`. 

## Backups

### Configuration

To set the folder where the backup will be created, create a `.env` file with:
```
BACKUP_PATH=./
```

### Create a backup

Run `sudo make backup`.

### Exclude folders

To prevent backups, create a `nobackup` file anywhere.
