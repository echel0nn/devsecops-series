#!/bin/bash

# Define the domain suffix for your services (optional)
DOMAIN_SUFFIX=".local"

# Backup the current /etc/hosts file
sudo cp /etc/hosts /etc/hosts.bak

# Remove previous entries added by this script (marked with # Kubernetes Service)
sudo sed -i '/# Kubernetes Service/d' /etc/hosts

# Fetch service names and cluster IPs
sudo k3s kubectl get services -o json | jq -r '.items[] | "\(.spec.clusterIP) \(.metadata.name)"' | while read -r line; do
  IP=$(echo "$line" | awk '{print $1}')
  NAME=$(echo "$line" | awk '{print $2}')
  
  # Add entry to /etc/hosts
  if [ "$IP" != "None" ]; then
    echo "$IP $NAME$DOMAIN_SUFFIX # Kubernetes Service" | sudo tee -a /etc/hosts > /dev/null
  fi
done

echo "Hosts file updated successfully!"
