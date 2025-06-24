#!/bin/bash -e

# Clone the Randomness-Provider repository and put it in /root/ directory
apt-get update
apt-get install -y git
cd /root
git clone https://github.com/RandAOLabs/Randomness-Provider.git
