#!/bin/bash -e

# Install git if not already installed
apt-get update
apt-get install -y git

# Clone the Randomness-Provider repository to /root/
cd /root
git clone https://github.com/RandAOLabs/Randomness-Provider.git

# Set appropriate permissions
chmod -R 700 /root/Randomness-Provider

# Enable Docker service to start on boot
systemctl enable docker.service
systemctl enable containerd.service
