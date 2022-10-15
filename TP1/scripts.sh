#! /bin/bash

# Constant variables
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Install python3
sudo apt-get install python3 python3-pip python3-venv -y

# Create and activate virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run Terraform 
chmod +x ./scripts/terraform.sh
cd ./scripts && ./terraform.sh up && cd ..

# Run Docker test container
printf "${BOLD} Running docker container${NORMAL}"
chmod +x ./scripts/docker.sh
cd ./scripts && ./docker.sh && cd ..

# Tear down infrastructure
cd terraform
printf "Tearing down infrastructure"
cd ./scripts && ./terraform.sh down && cd ..