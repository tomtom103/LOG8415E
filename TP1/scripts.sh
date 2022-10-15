#! /bin/bash

# TODO: This is the main script, everything should be launched from here

# Constant variables
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

sudo apt-get update -y && sudo apt-get upgrade -y

# Install python3
sudo apt-get install python3 python3-pip python3-venv -y

# Create and activate virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Add AWS credentials
printf "${BOLD}Adding AWS credentials in ~/.aws/credentials${NORMAL}"
chmod +x ./scripts/login.sh
./login.sh

# Run Terraform 
chmod +x ./scripts/terraform.sh
./scripts/terraform.sh up

# Run Docker test container
printf "${BOLD} Running docker container${NORMAL}"
chmod +x ./scripts/docker.sh
./scripts/docker.sh


# Tear down infrastructure
cd terraform
printf "Tearing down infrastructure"
./scripts/terraform.sh down