#!/bin/bash

set -euxo pipefail

# Create a shared directory
sudo mkdir -p /home/shared

# Make shared directory available to all users
sudo chmod -R 777 /home/shared/

# Install dependencies
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y libncurses5

cd /home/shared/
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster-community-data-node_7.6.6-1ubuntu18.04_amd64.deb

# Dependency of node bonary
sudo apt-get update && sudo apt-get install -y libclass-methodmaker-perl

# Install data node binary
sudo dpkg -i mysql-cluster-community-data-node_7.6.6-1ubuntu18.04_amd64.deb

# Data notes configuration
sudo touch /etc/my.cnf

echo """[mysql_cluster]
# Options for NDB Cluster processes:
ndb-connectstring=${master_ip}  # location of cluster manager
""" | sudo tee -a /etc/my.cnf

# Create data node data directory
sudo mkdir -p /usr/local/mysql/data

# Kill the manager before starting it as a service
sudo pkill -f ndbd

# Setup service config
sudo touch /etc/systemd/system/ndbd.service

echo """[Unit]
Description=MySQL NDB Data Node Daemon
After=network.target auditd.service

[Service]
Type=forking
ExecStart=/usr/sbin/ndbd
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
""" | sudo tee -a /etc/systemd/system/ndbd.service

# Reload system-ctl daemon
sudo systemctl daemon-reload

# Enable the service
sudo systemctl enable ndbd

# Start the service
sudo systemctl start ndbd

# # We create a file to signal that the script has finished
touch /tmp/finished-user-data