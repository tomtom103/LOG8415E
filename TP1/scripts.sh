# #! /bin/bash

# Constant variables
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Create and activate virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run Terraform 
chmod +x ./scripts/terraform.sh
cd ./scripts && ./terraform.sh up && cd ..

echo "Waiting 15 seconds for ALB to be ready..."
sleep 15

# Run Docker test container
printf "${BOLD} Running docker container${NORMAL}\n"
echo "$(pwd)"
chmod +x ./scripts/docker.sh
cd ./scripts && ./docker.sh && cd ..

# Tear down infrastructure
printf "Tearing down infrastructure"
cd ./scripts && ./terraform.sh down && cd ..