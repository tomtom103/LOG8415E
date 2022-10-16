#!/bin/bash

# Build Docker images
docker image build -t metrics:latest ../
docker image build -t requests:latest -f ../requests/Dockerfile ../

# # Run requests container
docker run --rm -t -v ~/.aws/:/root/.aws:ro requests:latest 

# Sleep for 60 seconds to allow the metrics to be present
echo "Sleeping for 60 seconds to allow metrics to be present"
sleep 60

# Run Docker container for the metrics
container_id="$(docker run -t -d -P -v ~/.aws/:/root/.aws:ro metrics:latest)"
echo "Launched docker image for metrics: $container_id"

# Waiting for metrics to be done since we don't wait for the container to run
echo "Waiting for metrics to be done"
sleep 15 

# Copy plots from container to host
sudo docker cp $container_id:/usr/app/src/metrics/target-group-avg-res.png ../metrics/target-group-avg-res.png
sudo docker cp $container_id:/usr/app/src/metrics/elb-plots.png ../metrics/elb-plots.png
sudo docker cp $container_id:/usr/app/src/metrics/target-group-reqs.png ../metrics/target-group-reqs.png

# Stop and delete docker container
docker stop $container_id
docker rm $container_id
