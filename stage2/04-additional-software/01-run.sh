#!/bin/bash -e

# Copy the RaspiWiFi setup script to the root directory
install -m 755 files/raspiwifi-setup.sh "${ROOTFS_DIR}/root/"

# Copy the systemd service file
install -m 644 files/raspiwifi-setup.service "${ROOTFS_DIR}/etc/systemd/system/"

# Enable the service to run on boot
on_chroot << EOF
systemctl enable raspiwifi-setup.service
EOF
