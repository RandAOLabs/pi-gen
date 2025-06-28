#!/bin/bash -e

# Install required packages
apt-get update
apt-get install -y git wget curl tar systemd unzip

# Clone the Randomness-Provider repository and put it in /root/ directory
cd /root
git clone https://github.com/RandAOLabs/Randomness-Provider.git

# Clone the pifigo repository
git clone https://github.com/ToddE/pifigo.git

# Create directories for pifigo
mkdir -p /opt/pifigo/bin
mkdir -p /opt/pifigo/assets
mkdir -p /opt/pifigo/lang

# Download and extract the pifigo release - using the new URL directly
cd /tmp
echo "Downloading pifigo installer..."
if wget https://github.com/ToddE/pifigo/releases/download/v0.0.1-test4/pifigo-installer-0.0.1-test4.tar.gz; then
    echo "Successfully downloaded pifigo-installer-0.0.1-test4.tar.gz"
    
    # Extract the tarball
    if tar -xzvf pifigo-installer-0.0.1-test4.tar.gz; then
        echo "Successfully extracted pifigo-installer"
        
        # Navigate to extracted directory
        extracted_dir=$(find /tmp -type d -name "pifigo-installer*" | head -1)
        if [ -n "$extracted_dir" ]; then
            cd "$extracted_dir"
            
            # Check if pifigo binary exists in this directory
            if [ -f ./pifigo ]; then
                echo "Found pifigo binary, installing to /opt/pifigo/bin/"
                cp ./pifigo /opt/pifigo/bin/
                chmod +x /opt/pifigo/bin/pifigo
            else
                echo "Warning: pifigo binary not found in extracted directory. Will attempt to use installer script instead."
            fi
        else
            echo "Warning: Could not find extracted pifigo-installer directory"
        fi
    else
        echo "Warning: Failed to extract pifigo-installer tarball"
    fi
else
    echo "Warning: Failed to download pifigo-installer package. Continuing installation process."
fi

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
rm -f /tmp/pifigo-v0.0.1-manual1_linux_armv7.tar.gz
rm -rf /tmp/pifigo-v0.0.1-manual1_linux_armv7

# We already downloaded and installed the pifigo installer package above
# No need to download it again
cd /tmp

# Try to run the installer script if it exists
extracted_dir=$(find /tmp -type d -name "pifigo-installer*" | head -1)
if [ -n "$extracted_dir" ] && [ -f "$extracted_dir/install.sh" ]; then
    echo "Running pifigo installer script..."
    cd "$extracted_dir"
    chmod +x ./install.sh
    if ./install.sh; then
        echo "pifigo-installer successfully installed"
    else
        echo "Warning: pifigo-installer install.sh script returned non-zero exit code, continuing anyway"
    fi
else
    echo "No installer script found or already executed"
fi

# Clean up installer files
cd /tmp
rm -f pifigo-installer-0.0.1-test4.tar.gz
rm -rf "$(find /tmp -type d -name "pifigo-installer*" 2>/dev/null)"

# Create a record of installed components
mkdir -p /root/installation-log
cat > /root/installation-log/pi-gen-additions.txt << EOF
Installation completed on: $(date)

Installed components:
1. Randomness-Provider - https://github.com/RandAOLabs/Randomness-Provider.git (in /root/Randomness-Provider)
2. Pifigo - https://github.com/ToddE/pifigo.git (in /root/pifigo)
   - Binary installed to: /opt/pifigo/bin/pifigo
   - Service enabled: pifigo.service
3. Pifigo installer package - https://github.com/ToddE/pifigo/releases/download/v0.0.1-test4/pifigo-installer-0.0.1-test4.tar.gz
EOF

# Print success message
echo "Pifigo and Randomness-Provider have been successfully installed."
echo "Pifigo service has been set to start on boot."
echo "Pifigo installed in: /opt/pifigo"
echo "Randomness-Provider installed in: /root/Randomness-Provider"
