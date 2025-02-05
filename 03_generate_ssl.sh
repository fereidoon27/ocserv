#!/bin/bash

# Prompt the user to enter the domain name
read -p "Enter your domain name (e.g., vpn.example.com): " DOMAIN

# Validate that a domain name was entered
if [[ -z "$DOMAIN" ]]; then
  echo "Error: No domain name entered. Exiting."
  exit 1
fi

# Define email for Certbot
EMAIL="fereidoon.hermes@gmail.com"

# Step 1: Install/Refresh Snapd
echo "Ensuring Snapd is installed and updated..."
snap install core
snap refresh core

# Step 2: Install Certbot via Snap
echo "Installing Certbot..."
snap install --classic certbot

# Step 3: Create a symlink for Certbot (if not already set)
echo "Creating a symlink for Certbot..."
ln -sf /snap/bin/certbot /usr/bin/certbot

# Step 4: Ensure port 80 is open for standalone validation
echo "Allowing port 80 temporarily for SSL validation..."
ufw allow http

# Step 5: Obtain an SSL certificate
echo "Requesting SSL certificate for $DOMAIN..."
certbot certonly --standalone --agree-tos --no-eff-email --staple-ocsp --preferred-challenges http \
  -m "$EMAIL" -d "$DOMAIN"

# Step 6: Verify the certificate was issued
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
  echo "SSL certificate for $DOMAIN generated successfully."
else
  echo "SSL certificate generation failed for $DOMAIN. Check Certbot logs."
  exit 1
fi

# Step 7: Set up automatic renewal
echo "Verifying Certbot renewal process..."
systemctl list-timers | grep certbot
certbot renew --dry-run

echo "SSL certificate setup completed for $DOMAIN."
