#!/bin/bash -e

# Create directory for Docker GPG key
install -m 0755 -d "${ROOTFS_DIR}/etc/apt/keyrings"

# Copy Docker repository configuration
install -m 644 files/docker.list "${ROOTFS_DIR}/etc/apt/sources.list.d/"

# Replace RELEASE placeholder with actual release name
sed -i "s/RELEASE/${RELEASE}/g" "${ROOTFS_DIR}/etc/apt/sources.list.d/docker.list"

# Download Docker GPG key directly to the target location
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o "${ROOTFS_DIR}/etc/apt/keyrings/docker.gpg"
chmod a+r "${ROOTFS_DIR}/etc/apt/keyrings/docker.gpg"

# Update package lists in chroot
on_chroot << EOF
apt-get update
EOF
