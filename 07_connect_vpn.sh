#!/bin/bash

# Step 1: Prompt for VPN server and credentials
read -p "Enter your VPN server domain (e.g., vpn.example.com): " VPN_SERVER
read -p "Enter your VPN username: " VPN_USER
read -s -p "Enter your VPN password: " VPN_PASS
echo

# Validate input
if [[ -z "$VPN_SERVER" || -z "$VPN_USER" || -z "$VPN_PASS" ]]; then
  echo "Error: Server, username, or password cannot be empty."
  exit 1
fi

# Step 2: Install OpenConnect client if not installed
if ! command -v openconnect &> /dev/null; then
  echo "Installing OpenConnect client..."
  apt update && apt install -y openconnect
fi

# Step 3: Connect to the VPN
echo "Connecting to VPN server $VPN_SERVER..."
echo "$VPN_PASS" | openconnect -b "$VPN_SERVER" -u "$VPN_USER" --passwd-on-stdin

# Step 4: Verify connection
sleep 5
if ip a | grep -q "tun0"; then
  echo "VPN connection established successfully."
else
  echo "VPN connection failed."
  exit 1
fi
