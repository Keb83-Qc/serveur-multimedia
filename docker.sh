# Installation de Docker 
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    apt-transport-https \
    software-properties-common \
    lsb-release

# Add Docker's official GPG key:
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-cache policy docker-ce

sudo apt-get update -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo systemctl status docker
sudo usermod -aG docker $USER
docker compose version

sudo service docker start && docker -v && sudo docker run hello-world

_user="$(id -u -n)" && _fichier="install.sh" && sudo usermod -aG docker $USER && > .env

chmod 700 /home/$USER/.env
