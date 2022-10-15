#!/bin/bash

# Build Docker images
docker image build -t metrics:latest .
docker image build -t requests:latest ./requests

# Run requests container
docker run --rm -t -d -P requests:latest 

# Sleep for 60 seconds to allow the metrics to be present
sleep 60

# Run Docker container
container_id=$(docker run -t -d -P metrics:latest)

# Copy plots from container to host
sudo docker cp $container_id:/usr/app/src/metrics/target-group-avg-res.png ./metrics
sudo docker cp $container_id:/usr/app/src/metrics/elb-plots.png ./metrics
sudo docker cp $container_id:/usr/app/src/metrics/target-group-reqs.png ./metrics
sudo docker cp $container_id:/usr/app/src/metrics/target-group-avg-req.png ./metrics

# Stop and delete docker container
docker stop $container_id
docker rm $container_id
