#!/bin/bash

# Create a shared directory
sudo mkdir -p /home/shared

# Make shared directory available to all users
sudo chmod -R 777 /home/shared/

# Install dependencies
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y libncurses5

cd /home/shared
wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster-community-management-server_7.6.6-1ubuntu18.04_amd64.deb

# Install mysql cluster community management server
sudo dpkg -i mysql-cluster-community-management-server_7.6.6-1ubuntu18.04_amd64.deb

# Create the mysql cluster file
sudo mkdir /var/lib/mysql-cluster

sudo touch /var/lib/mysql-cluster/config.ini

echo """[ndbd default]
# Options affecting ndbd processes on all data nodes:
NoOfReplicas=3	# Number of replicas

[ndb_mgmd]
# Management process options:
hostname=${master_ip} # Hostname of the manager
datadir=/var/lib/mysql-cluster 	# Directory for the log files

[ndbd]
hostname=${slave_one} # Hostname/IP of the first data node
NodeId=2		# Node ID for this data node
datadir=/usr/local/mysql/data	# Remote directory for the data files

[ndbd]
hostname=${slave_two} # Hostname/IP of the first data node
NodeId=3			# Node ID for this data node
datadir=/usr/local/mysql/data	# Remote directory for the data files

[ndbd]
hostname=${slave_three} # Hostname/IP of the first data node
NodeId=4		# Node ID for this data node
datadir=/usr/local/mysql/data	# Remote directory for the data files

[mysqld]
# SQL node options:
hostname=${master_ip}
""" | sudo tee -a /var/lib/mysql-cluster/config.ini

# Kill the manager before starting it as a service
sudo pkill -f ndb_mgmd

# Setup service config
sudo touch /etc/systemd/system/ndb_mgmd.service

echo """[Unit]
Description=MySQL NDB Cluster Management Server
After=network.target auditd.service

[Service]
Type=forking
ExecStart=/usr/sbin/ndb_mgmd -f /var/lib/mysql-cluster/config.ini
ExecReload=/bin/kill -HUP \$MAINPID
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
""" | sudo tee -a /etc/systemd/system/ndb_mgmd.service

# Reload system-ctl daemon
sudo systemctl daemon-reload

# Enable the service
sudo systemctl enable ndb_mgmd

# Start the service
sudo systemctl start ndb_mgmd

# Download MySQL cluster server binary
cd /home/shared && sudo mkdir -p /home/shared/install

wget https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster_7.6.6-1ubuntu18.04_amd64.deb-bundle.tar

# Extract into new directory
sudo tar -xvf mysql-cluster_7.6.6-1ubuntu18.04_amd64.deb-bundle.tar -C /home/shared/install/

# Go into install directory
cd /home/shared/install

# Install required dependencies
sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install -y libaio1 libmecab2

# Extract dependencies in tar file
sudo dpkg -i mysql-common_7.6.6-1ubuntu18.04_amd64.deb
sudo dpkg -i mysql-cluster-community-client_7.6.6-1ubuntu18.04_amd64.deb
sudo dpkg -i mysql-client_7.6.6-1ubuntu18.04_amd64.deb

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

sudo DEBIAN_FRONTEND=noninteractive dpkg -i mysql-cluster-community-server_7.6.6-1ubuntu18.04_amd64.deb

# Install MySQL server binary
sudo dpkg -i mysql-server_7.6.6-1ubuntu18.04_amd64.deb

echo """
[mysqld]
# Options for mysqld process:
ndbcluster                      # run NDB storage engine

[mysql_cluster]
# Options for NDB Cluster processes:
ndb-connectstring=${master_ip}  # location of management server
""" | sudo tee -a /etc/mysql/my.cnf

# Restart mysql service
sudo systemctl restart mysql

# Make sure mysql is enabled
sudo systemctl enable mysql

# Start mysql service
sudo systemctl start mysql

# Install sysbench
sudo apt-get install -y sysbench

# Download the Sakila database example
wget -O /home/shared/sakila-db.tar.gz https://downloads.mysql.com/docs/sakila-db.tar.gz

# Extract the sakila database
tar -xvzf /home/shared/sakila-db.tar.gz -C /home/shared/

# Import the sakila database
# Make sure that the data is present
sudo mysql --user=root --password=root <<QUERY
SOURCE /home/shared/sakila-db/sakila-schema.sql;
SOURCE /home/shared/sakila-db/sakila-data.sql;
USE sakila;
SHOW FULL TABLES;
SELECT COUNT(*) FROM film;
SELECT COUNT(*) FROM film_text;
QUERY

# # We create a file to signal that the script has finished
touch /tmp/finished-user-data