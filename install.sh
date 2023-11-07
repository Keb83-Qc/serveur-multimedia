#!/bin/bash 

# Installation de Docker
sudo apt install -y curl software-properties-common && apt update
sudo apt install -y docker.io

docker -v
# Installation de Docker-Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

docker-compose -v

_user="$(id -u -n)"
_uid="$(id -u)"

sudo usermod -aG docker $_user

# Création fichier pour docker-compose
cat << EOF > .env
  TZ=America/New_York
  PUID=$_uid
  PGID=$_uid

  ROOT=/home/$_user

  # Tautulli
  TAUTULLI_PORT=8181
  # qbittorrent
  QBT_EULA=
  QBT_WEBUI_PORT=8080
  QBT_PORT=6881
  QBT_CONFIG_PATH=/home/$_user/qbittorent/config
  QBT_DOWNLOADS_PATH=/home/$_user/qbittorent/downloads
  # overseerr
  OVERSERR_PORT=5055
  # flaresolverr
  FLARESOLVERR_PORT=8191
  # plex https://www.plex.tv/claim/
  PLEXCLAIM=
EOF

cat <<- 'EOF' > docker-compose.yml
  version: "3"
    services:
        tautulli:
            image: ghcr.io/tautulli/tautulli
            container_name: tautulli
            restart: unless-stopped
            volumes:
            - ${ROOT}/tautulli:/config
            environment:
            - PUID=${PUID}
            - PGID=${PGID}
            - TZ=${TZ}
            ports:
            - ${TAUTULLI_PORT}:${TAUTULLI_PORT}
        qbittorrent:
            image: lscr.io/linuxserver/qbittorrent:latest
            container_name: qbittorrent
            environment:
            - PUID=${PUID}
            - PGID=${PGID}
            - TZ=${TZ}
            - QBT_EULA=${QBT_EULA}
            - QBT_WEBUI_PORT=${QBT_WEBUI_PORT}
            volumes:
            - ${QBT_CONFIG_PATH}:/config
            - ${QBT_DOWNLOADS_PATH}:/downloads
            ports:
            - ${QBT_PORT}:${QBT_PORT}/tcp
            - ${QBT_PORT}:${QBT_PORT}/udp
            - ${QBT_WEBUI_PORT}:${QBT_WEBUI_PORT}
            restart: always
            read_only: true
            stop_grace_period: 30m
            tmpfs:
            - /tmp
            tty: true
        jackett:
            container_name: jackett
            image: linuxserver/jackett:latest
            restart: unless-stopped
            network_mode: host
            environment:
            - PUID=${PUID}
            - PGID=${PGID}
            - TZ=${TZ}
            volumes:
            - /etc/localtime:/etc/localtime:ro
            - ${ROOT}/jackett/downloads/torrent-blackhole:/downloads
            - ${ROOT}/jackett/config/jackett:/config
        plex:
            container_name: plex
            image: lscr.io/linuxserver/plex:latest
            restart: unless-stopped
            environment:
            - PUID=${PUID}
            - PGID=${PGID}
            - TZ=${TZ}
            - PLEX_CLAIM=${PLEXCLAIM}
            - HOSTNAME="PlexServer"
            network_mode: host
            volumes:
            - ${ROOT}/plex-server/config/plex/db:/config
            - ${ROOT}/plex-server/config/plex/transcode:/transcode
            - ${ROOT}/plex-server/complete:/data
            - ${ROOT}/plex-server/tvseries:/tv
            - ${ROOT}/plex-server/movies:/movies
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
        sonarr:
            container_name: sonarr
            image: linuxserver/sonarr:latest
            restart: unless-stopped
            network_mode: host
            environment:
            - PUID=${PUID}
            - PGID=${PGID}
            - TZ=${TZ}
            volumes:
            - /etc/localtime:/etc/localtime:ro
            - ${ROOT}/sonarr/config/sonarr:/config
            - ${ROOT}/sonarr/complete/tv:/tv
            - ${ROOT}/sonarr/downloads:/downloads
        radarr:
            container_name: radarr
            image: linuxserver/radarr:latest
            restart: unless-stopped
            network_mode: host
            environment:
            - PUID=${PUID}
            - PGID=${PGID}
            - TZ=${TZ}
            volumes:
            - /etc/localtime:/etc/localtime:ro
            - ${ROOT}/radarr/config/radarr:/config
            - ${ROOT}/radarr/complete/movies:/movies
            - ${ROOT}/radarr/downloads:/downloads
        overseerr:
            image: lscr.io/linuxserver/overseerr:latest
            container_name: overseerr
            environment:
            - PUID=${PUID}
            - PGID=${PGID}
            - LOG_LEVEL=debug
            - TZ=${TZ}
            - PORT=${OVERSERR_PORT}
            ports:
            - ${OVERSERR_PORT}:${OVERSERR_PORT}
            volumes:
            - ${ROOT}/overseerr/appdata/config:/app/config
            restart: unless-stopped
        flaresolverr:
            image: ghcr.io/flaresolverr/flaresolverr:latest
            container_name: flaresolverr
            environment:
            - LOG_LEVEL=${LOG_LEVEL:-info}
            - LOG_HTML=${LOG_HTML:-false}
            - CAPTCHA_SOLVER=${CAPTCHA_SOLVER:-none}
            - TZ=${TZ}
            ports:
            - ${FLARESOLVERR_PORT}:${FLARESOLVERR_PORT}
            restart: unless-stopped
EOF
