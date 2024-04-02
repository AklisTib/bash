#!/bin/bash

# Check if the target IP is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <target_ip>"
  exit 1
fi

TARGET_IP=$1

# Specify the range of ports to scan (e.g., 1-1024)
PORT_RANGE="1-1024"

echo "Scanning port range $PORT_RANGE on $TARGET_IP"

# Use a for loop to iterate through the ports in the specified range
for PORT in $(seq $PORT_RANGE); do
  # Check if the port is open using the netcat (nc) command
  nc -v $TARGET_IP $PORT &> /dev/null

  # Check the exit status of the previous command
  if [ $? -eq "0" ]; then
    echo "Port $PORT is open."
  else
    echo "Port $PORT is closed."
  fi
done
