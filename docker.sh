# Installation de Docker

# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg software-properties-common -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo service docker start && docker -v && sudo docker run hello-world

# Installation de Docker-Compose

sudo apt-get update
sudo apt-get install docker-compose-plugin -y

docker compose version

sudo usermod -aG docker $_user

# Création fichier d'installation

_user="$(id -u -n)" && _fichier="install.sh" && sudo usermod -aG docker $_user && > $_fichier

chmod 700 /home/$_user/$_fichier
