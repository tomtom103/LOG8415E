#!/bin/bash

set -e

docker build -t thomascaron103/log8415_tp2:latest .
docker run -it -v "$(pwd)/out":/root/out:rw -p 8088:8088 thomascaron103/log8415_tp2

echo "Finished"