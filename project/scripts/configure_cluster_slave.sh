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

echo "Master IP is ${master_ip}" >&3

# # We create a file to signal that the script has finished
touch /tmp/finished-user-data