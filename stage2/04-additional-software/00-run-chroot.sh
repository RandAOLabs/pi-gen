#!/bin/bash -e

# Clone required repositories and put them in /root/ directory
apt-get update
apt-get install -y git python3 python3-pip
cd /root

# Clone Randomness-Provider repository
git clone https://github.com/RandAOLabs/Randomness-Provider.git

# Clone RaspiWiFi repository
git clone https://github.com/jasbur/RaspiWiFi.git
