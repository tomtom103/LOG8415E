#! /bin/bash

# TODO: This is the main script, everything should be launched from here

echo "Hello World!"

instance_id = "$(ec2-metadata -i)"
echo "
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return $instance_id

" > app.py