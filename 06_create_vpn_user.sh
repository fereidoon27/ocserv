#!/bin/bash

# Step 1: Prompt for VPN username and password
read -p "Enter the VPN username: " VPN_USER
read -s -p "Enter the VPN password: " VPN_PASS
echo

# Validate input
if [[ -z "$VPN_USER" || -z "$VPN_PASS" ]]; then
  echo "Error: Username or password cannot be empty."
  exit 1
fi

# Ensure ocserv password file exists
if [[ ! -f "/etc/ocserv/ocpasswd" ]]; then
  echo "Creating ocserv password file..."
  touch /etc/ocserv/ocpasswd
fi

# Step 2: Add user to ocserv
echo "Adding user $VPN_USER to OpenConnect VPN..."
echo "$VPN_PASS" | ocpasswd -c /etc/ocserv/ocpasswd "$VPN_USER"

# Step 3: Verify user creation
echo "Verifying user creation..."
grep "$VPN_USER" /etc/ocserv/ocpasswd && echo "User $VPN_USER successfully created." || echo "Failed to create user."

# Step 4: Restart ocserv to apply changes
echo "Restarting OpenConnect VPN service..."
systemctl restart ocserv

echo "VPN user setup completed."
