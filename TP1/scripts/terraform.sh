#!/bin/bash

GREEN='\033[0;32m'
NOCOLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

cd terraform
printf "\n${BOLD}Running Terraform...${NORMAL} \n"
printf "\n  ${BOLD}STEP[1/4] : terraform init...${NORMAL}\n"
terraform init
printf "\n  ${BOLD}STEP[2/4] :${NORMAL} terraform validate... "
terraform validate

if [ $? -eq 0 ]; then
    printf "  ${BOLD}STEP[3/4] :${NORMAL} terraform plan...\n\n"
    terraform plan
    echo "  ${BOLD}STEP[4/4] :${NORMAL} terraform apply..."
    terraform apply -auto-approve
    if [ $? -eq 0 ]; then
        printf "\n${GREEN}Deployment succeeded! Use terraform destroy command to undo deployment${NOCOLOR}\n\n"
    fi
fi
