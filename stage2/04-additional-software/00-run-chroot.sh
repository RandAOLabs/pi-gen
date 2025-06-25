#!/bin/bash -e

# Install required packages
apt-get update
apt-get install -y git wget curl tar systemd

# Clone the Randomness-Provider repository and put it in /root/ directory
cd /root
git clone https://github.com/RandAOLabs/Randomness-Provider.git

# Clone the pifigo repository
git clone https://github.com/ToddE/pifigo.git

# Create directories for pifigo
mkdir -p /opt/pifigo/bin
mkdir -p /opt/pifigo/assets
mkdir -p /opt/pifigo/lang

# Download and extract the pifigo release
cd /tmp
wget https://github.com/ToddE/pifigo/releases/download/v0.0.1-manual1/pifigo-v0.0.1-manual1_linux_armv7.tar.gz
tar -xzvf pifigo-v0.0.1-manual1_linux_armv7.tar.gz -C /tmp

# Copy the binary to the installation directory
cp /tmp/pifigo /opt/pifigo/bin/
chmod +x /opt/pifigo/bin/pifigo

# Copy config and assets from the git repo
cp /root/pifigo/config.toml /opt/pifigo/
cp -r /root/pifigo/lang/* /opt/pifigo/lang/
cp -r /root/pifigo/cmd/pifigo/assets/* /opt/pifigo/assets/

# Create a systemd service to start pifigo on boot
cat > /etc/systemd/system/pifigo.service << EOL
[Unit]
Description=Pifigo Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/pifigo
ExecStart=/opt/pifigo/bin/pifigo
Restart=on-failure
RestartSec=5
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=pifigo

[Install]
WantedBy=multi-user.target
EOL

# Enable the service to start on boot
systemctl enable pifigo.service

# Cleanup
rm -f /tmp/pifigo-v0.0.1-manual1_linux_armv7.tar.gz
