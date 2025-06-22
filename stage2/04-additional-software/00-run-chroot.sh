#!/bin/bash -e

# Add Docker repository
apt-get update
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list
apt-get update

# Clone the Randomness-Provider repository to /root/
apt-get install -y git
cd /root
git clone https://github.com/RandAOLabs/Randomness-Provider.git

# Set appropriate permissions
chmod -R 700 /root/Randomness-Provider

# Enable Docker service to start on boot
systemctl enable docker.service
systemctl enable containerd.service
