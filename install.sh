#!/bin/bash 

_uid="$(id -u)"
_user="$(id -u -n)"
_fichier=".env"

# Création fichier pour docker-compose
cat << EOF > $_fichier
TZ=America/New_York
PUID=$_uid
PGID=$_uid

# Parametre
ROOT=/home/$_user
DATA=/srv
# plex https://www.plex.tv/claim/
PLEXCLAIM=
    
EOF

echo "Fichier $_fichier créer avec succès."
_fichier="docker-compose.yml"

cat <<- 'EOF' > $_fichier
version: "3"
services:
  plex:
  image: lscr.io/linuxserver/plex:latest
  container_name: plex
  network_mode: host
  environment:
    - PUID=${PUID}
    - PGID=${PGID}
    - TZ=${TZ}
    - VERSION=docker
    - PLEX_CLAIM=${PLEXCLAIM}
  volumes:
    - ${ROOT}/plex/config:/config
    - ${ROOT}/plex/transcode:/transcode
    - ${ROOT}/plex/data:/data
    - ${DATA}/plex/tvseries:/tv
    - ${DATA}/plex/movies:/movies
  ports:
    - 32400:32400
    - 1900:1900/udp
    - 5353:5353/udp
    - 8324:8324
    - 32410:32410/udp
    - 32412:32412/udp
    - 32413:32413/udp
    - 32414:32414/udp
    - 32469:32469
  restart: unless-stopped
  tautulli:
    image: lscr.io/linuxserver/tautulli:latest
    container_name: tautulli
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ${ROOT}/tautulli:/config
    ports:
      - 8181:8181
    restart: unless-stopped
  overseerr:
    image: lscr.io/linuxserver/overseerr:latest
    container_name: overseerr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ${ROOT}/overseerr/appdata/config:/config
    ports:
      - 5055:5055
    restart: unless-stopped
  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ${ROOT}/sonarr/config:/config
    ports:
      - 8989:8989
    restart: unless-stopped
  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - ${ROOT}/radarr/config:/config
    ports:
      - 7878:7878
    restart: unless-stopped
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - WEBUI_PORT=8080
    volumes:
      - ${ROOT}/qbittorent/config:/config
      - ${DATA}/downloads:/downloads
    ports:
      - 8080:8080
      - 6881:6881
      - 6881:6881/udp
    restart: unless-stopped
  jackett:
    image: lscr.io/linuxserver/jackett:latest
    container_name: jackett
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - AUTO_UPDATE=true
    volumes:
      - ${ROOT}/jackett/downloads:/downloads
      - ${ROOT}/jackett/data:/config
    ports:
      - 9117:9117
    restart: unless-stopped
  flaresolverr:
    # DockerHub mirror flaresolverr/flaresolverr:latest
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    environment:
      - LOG_LEVEL=${LOG_LEVEL:-info}
      - LOG_HTML=${LOG_HTML:-false}
      - CAPTCHA_SOLVER=${CAPTCHA_SOLVER:-none}
      - TZ=${TZ}
    ports:
      - "${PORT:-8191}:8191"
    restart: unless-stopped
  wizarr:
    container_name: wizarr
    image: ghcr.io/wizarrrr/wizarr:latest
    ports:
      - 5690:5690
    volumes:
      - ${ROOT}/wizarr/database:/data/database
EOF

echo "Fichier $_fichier créer avec succès."
echo "sudo docker compose up -d pour debuté"
echo "sudo docker compose help pour de l'aide"
