#!/bin/bash

# Navigate to the RaspiWiFi directory
cd /root/RaspiWiFi

# Run the setup script and log output
python3 initial_setup.py > /root/raspiwifi-setup.log 2>&1

# Indicate completion in the log
echo "RaspiWiFi setup completed at $(date)" >> /root/raspiwifi-setup.log
