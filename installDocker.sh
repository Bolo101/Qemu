#!/bin/bash

# Exit on any error
set -e

# Update system package list
echo "Updating system package list..."
sudo apt update -y

# Install prerequisites for Docker
echo "Installing required dependencies..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the Docker stable repository for Debian (bullseye, compatible with Kali)
echo "Setting up Docker repository..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package list again to include Docker packages
echo "Updating package list to include Docker..."
sudo apt update -y

# Install Docker Engine
echo "Installing Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Verify Docker installation
echo "Verifying Docker installation..."
sudo systemctl start docker
sudo systemctl enable docker
sudo docker --version

# Allow your user to run Docker commands without 'sudo'
echo "Adding current user to docker group..."
sudo usermod -aG docker $USER

echo "Docker installation complete! Please log out and log back in to use Docker without 'sudo'."
