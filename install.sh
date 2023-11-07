#!/bin/bash    
# Installation de Docker
sudo apt install -y curl software-properties-common && apt update
sudo apt install -y docker.io

docker -v
# Installation de Docker-Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

docker-compose -v

sudo usermod -aG docker kbecois

# Création fichier pour docker-compose
> .env
> docker-compose.yml
