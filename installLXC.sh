#!/bin/bash

# This script installs LXC (Linux Containers) on your system

# Check if the user is root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root!" 1>&2
    exit 1
fi

# Update package lists
echo "Updating package lists..."
apt-get update -y

# Install LXC and utilities
echo "Installing LXC and dependencies..."
apt-get install -y lxc lxc-utils

# Install additional utilities for managing containers
echo "Installing additional utilities..."
apt-get install -y bridge-utils

# Check if the installation was successful
if command -v lxc-create >/dev/null 2>&1; then  # command -v check for lxc-create installation and returns path. Result is sent to /dev/null.
    echo "LXC has been successfully installed!" #  Both stderr and stdout are redirected to /dev/null
else
    echo "LXC installation failed. Please check for errors."
    exit 1
fi

# Display LXC version
echo "LXC version installed:"
lxc --version

# Instructions to create the container
echo "To create a new container, use the following command:"
echo "sudo lxc-create -n <container_name> -t download"
echo "You can then start the container with: sudo lxc-start -n <container_name>."
echo "To attach to the container, use: sudo lxc-attach -n <container_name>."

echo "LXC installation and setup completed successfully!"

