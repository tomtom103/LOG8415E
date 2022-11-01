#!/bin/bash

set -euxo pipefail

sudo apt-get update -y && sudo apt-get upgrade -y

# Install required dependencies for docker
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release -y

# Create directory for keyrings
sudo mkdir -p /etc/apt/keyrings

# Add the docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add the docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Not necessary, just in case
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Update package index and install docker from official repo
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Create shared directory
sudo mkdir -p /home/shared

# Make sure that docker is installed
echo "$(sudo systemctl status docker)" > /home/shared/docker_status

# Allow the ubuntu user to use docker commands
sudo usermod -aG docker ubuntu

# Download our docker image in the EC2 instance
docker pull thomascaron103/log8415_tp2:latest

# Script to run docker image
echo "!/bin/bash

set -e

docker run -it -v /root/shared/out:/root/out:rw -p 8088:8088 thomascaron103/log8415_tp2:latest
" > /home/shared/run_docker.sh

chmod +x /home/shared/run_docker.sh

# Make shared directory available to all users...
chmod -R 777 /home/shared/

mkdir -p /home/shared/out

echo "Finished setup!"

# We create a file to signal that the script has finished
touch /tmp/finished-user-data