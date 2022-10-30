#!/bin/bash

set -e

docker pull thomascaron103/log8415_tp2:latest

docker build -t thomascaron103/log8415_tp2:latest .
docker run -it -p 50070:50070 -p 8088:8088 thomascaron103/log8415_tp2

echo "Finished"