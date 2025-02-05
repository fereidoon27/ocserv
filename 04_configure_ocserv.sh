#!/bin/bash

# Prompt the user for the domain name
read -p "Enter your domain name (e.g., vpn.example.com): " DOMAIN

# Validate that a domain name was entered
if [[ -z "$DOMAIN" ]]; then
  echo "Error: No domain name entered. Exiting."
  exit 1
fi

# Define the certificate paths based on the domain
CERT_PATH="/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
KEY_PATH="/etc/letsencrypt/live/$DOMAIN/privkey.pem"

# Check if the certificate files exist
if [[ ! -f "$CERT_PATH" || ! -f "$KEY_PATH" ]]; then
  echo "Error: SSL certificate files not found. Please run generate_ssl.sh first."
  exit 1
fi

# Step 1: Copy the sample ocserv configuration file (if not already exists)
if [[ ! -f "/etc/ocserv/ocserv.conf" ]]; then
  echo "Copying default ocserv configuration file..."
  mkdir -p /etc/ocserv
  cp /root/ocserv/doc/sample.config /etc/ocserv/ocserv.conf
fi

# Step 2: Configure OpenConnect VPN
echo "Configuring OpenConnect VPN..."

# Modify ocserv.conf dynamically
sed -i "s|auth = .*|auth = \"plain[passwd=/etc/ocserv/ocpasswd]\"|" /etc/ocserv/ocserv.conf
sed -i "s|server-cert = .*|server-cert = $CERT_PATH|" /etc/ocserv/ocserv.conf
sed -i "s|server-key = .*|server-key = $KEY_PATH|" /etc/ocserv/ocserv.conf
sed -i "s|#tcp-port = 443|tcp-port = 443|" /etc/ocserv/ocserv.conf
sed -i "s|#udp-port = 443|#udp-port = 443|" /etc/ocserv/ocserv.conf  # Disabling UDP for now
sed -i "s|max-clients = .*|max-clients = 100|" /etc/ocserv/ocserv.conf
sed -i "s|max-same-clients = .*|max-same-clients = 5|" /etc/ocserv/ocserv.conf
sed -i "s|#default-domain = .*|default-domain = $DOMAIN|" /etc/ocserv/ocserv.conf
sed -i "s|ipv4-network = .*|ipv4-network = 10.10.10.0|" /etc/ocserv/ocserv.conf
sed -i "s|#tunnel-all-dns = .*|tunnel-all-dns = true|" /etc/ocserv/ocserv.conf
sed -i "s|#dns = 8.8.8.8|dns = 8.8.8.8|" /etc/ocserv/ocserv.conf
sed -i "s|#dns = 8.8.4.4|dns = 8.8.4.4|" /etc/ocserv/ocserv.conf
sed -i "s|keepalive = .*|keepalive = 60|" /etc/ocserv/ocserv.conf
sed -i "s|#try-mtu-discovery = .*|try-mtu-discovery = true|" /etc/ocserv/ocserv.conf
sed -i "s|#idle-timeout = .*|idle-timeout = 1200|" /etc/ocserv/ocserv.conf
sed -i "s|#mobile-idle-timeout = .*|mobile-idle-timeout = 1800|" /etc/ocserv/ocserv.conf

# Step 3: Restart ocserv service to apply changes
echo "Restarting OpenConnect VPN service..."
systemctl restart ocserv
systemctl enable ocserv

# Step 4: Verify ocserv service status
echo "Verifying OpenConnect VPN service status..."
systemctl status ocserv --no-pager

echo "OpenConnect VPN configuration completed for $DOMAIN."
