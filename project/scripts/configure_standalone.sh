#!/bin/bash

sudo apt-get update -y && sudo apt-get upgrade -y

# Install required dependencies
sudo apt-get install -y mysql-server sysbench

# Ensure that the sql server is running
sudo systemctl start mysql.service

# Create a database called projet
# Create a user for ubuntu with all privileges on projet
# Flush privileges to clear the cache
sudo mysql <<QUERY
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
CREATE USER IF NOT EXISTS 'ubuntu'@'localhost' IDENTIFIED BY 'ubuntu';
GRANT ALL PRIVILEGES ON *.* TO 'ubuntu'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
QUERY

# Create a shared directory
sudo mkdir -p /home/shared

# Make shared directory available to all users
chmod -R 777 /home/shared/

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

# # Prepare statement with sysbench to generate a table for performing tests
sysbench oltp_read_write --table-size=1000000 --mysql-db=sakila --mysql-user=root --mysql-password=root prepare

# # Execute performance test
sysbench oltp_read_write --table-size=1000000 --mysql-db=sakila --mysql-user=root --mysql-password=root --threads=6 --time=60 --max-requests=0 run > /home/shared/testbench-result.log

echo "Testbench results:\n\n"
cat /home/shared/testbench-result.log

# # We create a file to signal that the script has finished
touch /tmp/finished-user-data