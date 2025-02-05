#!/bin/bash

# Step 1: Update and upgrade the system
echo "Updating and upgrading the system..."
apt update && apt upgrade -y

# Step 2: Install required packages
echo "Installing necessary system packages..."
apt install -y wget curl nano software-properties-common dirmngr apt-transport-https gnupg2 \
  ca-certificates lsb-release ubuntu-keyring unzip ufw git

# Step 3: Configure the firewall
echo "Configuring the firewall..."
ufw allow OpenSSH         # Allow SSH access
ufw allow http            # Allow HTTP for Certbot standalone challenge
ufw allow https           # Allow HTTPS for VPN traffic
ufw --force enable        # Enable the firewall with force to avoid prompts

# Step 4: Verify firewall status
echo "Firewall configured with the following rules:"
ufw status verbose

echo "System setup and prerequisites completed."

sudo apt install git -y
