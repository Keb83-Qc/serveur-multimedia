#!/bin/bash 

_uid="$(id -u)"
_user="$(id -u -n)"

# Création fichier pour docker-compose
cat << EOF > .env
    TZ=America/New_York
    PUID=$_uid
    PGID=$_uid

    ROOT=/home/$_user
    DATA=/srv

    # Tautulli
    TAUTULLI_PORT=8181
    # qbittorrent
    QBT_WEBUI_PORT=8080
    QBT_PORT=6881
    # Jackett
    JACKETT_PORT=9117
    # plex https://www.plex.tv/claim/
    PLEXCLAIM=
    # Sonarr
    SONARR_PORT=8989
    # Radarr
    RADARR_PORT=7878
    # overseerr
    OVERSERR_PORT=5055
    # flaresolverr
    FLARESOLVERR_PORT=8191
EOF

echo "Fichier .env a bien été créer"

cat <<- 'EOF' > docker-compose.yml
    version: "3"
    services:

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
        - ${TAUTULLI_PORT}:${TAUTULLI_PORT}
        restart: unless-stopped

    qbittorrent:
        image: lscr.io/linuxserver/qbittorrent:latest
        container_name: qbittorrent
        environment:
        - PUID=${PUID}
        - PGID=${PGID}
        - TZ=${TZ}
        - QBT_WEBUI_PORT=${QBT_WEBUI_PORT}
        volumes:
        - ${ROOT}/qbittorent/config:/config
        - ${DATA}/downloads:/downloads
        ports:
        - ${QBT_PORT}:${QBT_PORT}/tcp
        - ${QBT_PORT}:${QBT_PORT}/udp
        - ${QBT_WEBUI_PORT}:${QBT_WEBUI_PORT}
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
        - /etc/localtime:/etc/localtime:ro
        - ${ROOT}/jackett/downloads:/downloads
        - ${ROOT}/jackett/data:/config
        ports:
        - ${JACKETT_PORT}:${JACKETT_PORT}
        restart: unless-stopped

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

    sonarr:
        image: lscr.io/linuxserver/sonarr:latest
        container_name: sonarr
        environment:
        - PUID=${PUID}
        - PGID=${PGID}
        - TZ=${TZ}
        volumes:
        - /etc/localtime:/etc/localtime:ro
        - ${ROOT}/sonarr/config:/config
        ports:
        - ${SONARR_PORT}:${SONARR_PORT}
        restart: unless-stopped

    radarr:
        image: lscr.io/linuxserver/radarr:latest
        container_name: radarr
        environment:
        - PUID=${PUID}
        - PGID=${PGID}
        - TZ=${TZ}
        volumes:
        - /etc/localtime:/etc/localtime:ro
        - ${ROOT}/radarr/config:/config
        ports:
        - ${RADARR_PORT}:${RADARR_PORT}
        restart: unless-stopped

    overseerr:
        image: lscr.io/linuxserver/overseerr:latest
        container_name: overseerr
        environment:
        - PUID=${PUID}
        - PGID=${PGID}
        - LOG_LEVEL=debug
        - TZ=${TZ}
        - PORT=${OVERSERR_PORT}
        volumes:
        - ${ROOT}/overseerr/appdata/config:/config
        ports:
        - ${OVERSERR_PORT}:${OVERSERR_PORT}
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
echo "Fichier docker-compose.yml a bien été créer"
