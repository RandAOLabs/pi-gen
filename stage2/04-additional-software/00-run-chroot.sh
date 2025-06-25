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
wget https://github.com/ToddE/pifigo/releases/download/v0.0.1-test4/pifigo-installer-0.0.1-test4.tar.gz
tar -xzvf pifigo-installer-0.0.1-test4.tar.gz

# Check the directory structure after extraction
ls -la /tmp
find /tmp -name "pifigo" -type f

# Copy the binary to the installation directory (adjusting path based on actual structure)
if [ -f "/tmp/pifigo" ]; then
    cp /tmp/pifigo /opt/pifigo/bin/
elif [ -f "/tmp/pifigo-installer-0.0.1-test4/pifigo" ]; then
    cp /tmp/pifigo-installer-0.0.1-test4/pifigo /opt/pifigo/bin/
elif [ -f "/tmp/pifigo_linux_armv7/pifigo" ]; then
    cp /tmp/pifigo_linux_armv7/pifigo /opt/pifigo/bin/
else
    # Look for the binary in any subdirectory
    PIFIGO_PATH=$(find /tmp -name "pifigo" -type f | head -1)
    if [ -n "$PIFIGO_PATH" ]; then
        cp "$PIFIGO_PATH" /opt/pifigo/bin/
    else
        echo "ERROR: Could not find pifigo binary in extracted files!"
        exit 1
    fi
fi

chmod +x /opt/pifigo/bin/pifigo

# Create default config.toml if it doesn't exist in repo
echo "Creating default config if needed..."
if [ ! -f "/root/pifigo/config.toml" ]; then
    echo "Creating default config.toml..."
    cat > /opt/pifigo/config.toml << EOF
# Pifigo Configuration
title = "Pifigo"
port = 8080

[server]
address = "0.0.0.0"
EOF
else
    cp /root/pifigo/config.toml /opt/pifigo/
fi

# Create language and asset dirs if they don't exist
echo "Setting up language and assets..."
mkdir -p /opt/pifigo/lang
mkdir -p /opt/pifigo/assets

# Copy lang files if they exist
if [ -d "/root/pifigo/lang" ] && [ "$(ls -A /root/pifigo/lang)" ]; then
    cp -r /root/pifigo/lang/* /opt/pifigo/lang/
fi

# Copy assets if they exist
if [ -d "/root/pifigo/cmd/pifigo/assets" ] && [ "$(ls -A /root/pifigo/cmd/pifigo/assets)" ]; then
    cp -r /root/pifigo/cmd/pifigo/assets/* /opt/pifigo/assets/
elif [ -d "/root/pifigo/assets" ] && [ "$(ls -A /root/pifigo/assets)" ]; then
    cp -r /root/pifigo/assets/* /opt/pifigo/assets/
fi

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

# Cleanup temporary files
rm -f /tmp/pifigo-installer-0.0.1-test4.tar.gz
rm -rf /tmp/pifigo-installer-0.0.1-test4
rm -rf /tmp/pifigo_linux_armv7 2>/dev/null

# Print success message
echo "Pifigo and Randomness-Provider have been successfully installed."
echo "Pifigo service has been set to start on boot."
echo "Pifigo installed in: /opt/pifigo"
echo "Randomness-Provider installed in: /root/Randomness-Provider"
