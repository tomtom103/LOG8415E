#!/bin/bash

# Create a shared directory
sudo mkdir -p /home/shared

# Make shared directory available to all users
sudo chmod -R 777 /home/shared/

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/home/shared/output.log 2>&1

# If you want to print to stdout: echo "$(date) : part 1 - start" >&3

set -euxo pipefail

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

# Start data node
sudo ndbd >&3

# Kill the manager before starting it as a service
sudo pkill -f ndb_mgmd

# Setup service config
sudo touch /etc/systemd/system/ndb_mgmd.service

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

# Get service status into console
sudo systemctl status ndbd >&3

# # We create a file to signal that the script has finished
touch /tmp/finished-user-data