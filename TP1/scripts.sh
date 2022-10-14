#! /bin/bash

# TODO: This is the main script, everything should be launched from here

# Constant variables
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

sudo apt-get update -y && sudo apt-get upgrade -y

# Redirect all requests to port 80 to port 5000
# sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 5000

# Install python3
sudo apt-get install python3 python3-pip python3-venv -y

# Create and activate virtual environment
python3 -m venv ~/.venv
source ~/.venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Add AWS credentials
echo "${BOLD}Adding AWS credentials in ~/.aws/credentials${NORMAL}"
chmod +x login.sh && ./login.sh

# Run Terraform 
chmod +x /scripts/terraform.sh && ./scripts/terraform.sh

# Run Docker test container
# docker image build -t metrics:0.0.1 ./..
# docker run metrics:0.0.1

