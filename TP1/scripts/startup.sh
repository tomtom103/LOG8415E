#!/bin/bash

sudo apt-get update -y && sudo apt-get upgrade -y

# Redirect all requests to port 80 to port 5000
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 5000

# Install python3
sudo apt-get install python3 python3-pip python3-venv -y

cd /home

# Create and activate virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install flask

# instance_name is provided by the templated terraform templatefile() function
echo "from flask import Flask, Response

app = Flask(__name__)

@app.route('/cluster1')
def cluster1():
    return 'Hello from Cluster 1, Instance ID: ${instance_name}'

@app.route('/cluster2')
def cluster2():
    return 'Hello from Cluster 2, Instance ID: ${instance_name}'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
" > app.py

PYTHONUNBUFFERED=1 nohup python app.py &