Plex

to set the library path, create a "docker-compose.override.yml" with:

services:
  plex:
    volumes:
      - [path to library root]:/data