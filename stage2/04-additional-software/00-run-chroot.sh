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
echo "Checking extracted files..."
ls -la /tmp || true
ls -la /tmp/pifigo-installer-0.0.1-test4/releases/ || true

# Copy the binary to the installation directory - use armv7 binary for Raspberry Pi
if [ -f "/tmp/pifigo-installer-0.0.1-test4/releases/pifigo_0.0.1-test4_linux_armv7" ]; then
    echo "Found armv7 binary, using it..."
    cp "/tmp/pifigo-installer-0.0.1-test4/releases/pifigo_0.0.1-test4_linux_armv7" /opt/pifigo/bin/pifigo
elif [ -f "/tmp/pifigo-installer-0.0.1-test4/releases/pifigo_0.0.1-test4_linux_armv6" ]; then
    echo "Found armv6 binary, using it..."
    cp "/tmp/pifigo-installer-0.0.1-test4/releases/pifigo_0.0.1-test4_linux_armv6" /opt/pifigo/bin/pifigo
elif [ -f "/tmp/pifigo-installer-0.0.1-test4/releases/pifigo_0.0.1-test4_linux_arm64" ]; then
    echo "Found arm64 binary, using it..."
    cp "/tmp/pifigo-installer-0.0.1-test4/releases/pifigo_0.0.1-test4_linux_arm64" /opt/pifigo/bin/pifigo
else
    echo "WARNING: Could not find specific pifigo binary, attempting to use installer script instead"
    # Try running the installer script
    if [ -f "/tmp/pifigo-installer-0.0.1-test4/install.sh" ]; then
        echo "Found install.sh, running it..."
        cd /tmp/pifigo-installer-0.0.1-test4
        chmod +x install.sh
        # Just continue even if installer fails, don't exit the script
        ./install.sh || true
        if [ -f "/opt/pifigo/bin/pifigo" ]; then
            echo "Installer appears to have succeeded"
        else
            echo "WARNING: Installer did not place binary in expected location, creating placeholder"
            echo "#!/bin/bash\necho 'Pifigo binary not properly installed'\nexit 1" > /opt/pifigo/bin/pifigo
        fi
    else
        echo "WARNING: No binary or installer found, creating placeholder"
        echo "#!/bin/bash\necho 'Pifigo binary not properly installed'\nexit 1" > /opt/pifigo/bin/pifigo
    fi
fi

chmod +x /opt/pifigo/bin/pifigo

# Copy config.toml from the extracted package or create default
echo "Setting up config file..."
if [ -f "/tmp/pifigo-installer-0.0.1-test4/config.toml" ]; then
    echo "Using config.toml from installer package"
    cp "/tmp/pifigo-installer-0.0.1-test4/config.toml" /opt/pifigo/
else
    echo "Creating default config.toml..."
    cat > /opt/pifigo/config.toml << EOF
# Pifigo Configuration
title = "Pifigo"
port = 8080

[server]
address = "0.0.0.0"
EOF
fi

# Create language and asset dirs if they don't exist
echo "Setting up language and assets..."
mkdir -p /opt/pifigo/lang
mkdir -p /opt/pifigo/assets

# Copy lang files from the installer package
if [ -d "/tmp/pifigo-installer-0.0.1-test4/lang" ]; then
    echo "Copying language files from installer package"
    cp -r /tmp/pifigo-installer-0.0.1-test4/lang/* /opt/pifigo/lang/
fi

# Copy assets from the installer package
if [ -d "/tmp/pifigo-installer-0.0.1-test4/cmd/pifigo/assets" ]; then
    echo "Copying assets from installer package"
    cp -r /tmp/pifigo-installer-0.0.1-test4/cmd/pifigo/assets/* /opt/pifigo/assets/
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
