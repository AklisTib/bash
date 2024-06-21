#!/bin/bash

# Define the data directory for persistent storage
DATA_DIR="/srv/gitlab"

# Create the data directory if it doesn't exist
mkdir -p $DATA_DIR

# Pull the GitLab Docker image
docker pull gitlab/gitlab-ce:latest

# Run the GitLab container
docker run --detach \
  --hostname gitlab.test.com \
  --publish 443:443 --publish 80:80 --publish 22:22 \
  --name gitlab \
  --restart always \
  --volume $DATA_DIR/config:/etc/gitlab \
  --volume $DATA_DIR/logs:/var/log/gitlab \
  --volume $DATA_DIR/data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest

echo "GitLab is now running. Access it at http://localhost or http://your-server-ip"