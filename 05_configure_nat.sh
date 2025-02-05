#!/bin/bash

# Step 1: Enable IP forwarding
echo "Enabling IP forwarding..."
echo "net.ipv4.ip_forward = 1" | tee /etc/sysctl.d/60-custom.conf

# Enable TCP BBR for better network performance
echo "Enabling TCP BBR congestion control..."
echo "net.core.default_qdisc=fq" | tee -a /etc/sysctl.d/60-custom.conf
echo "net.ipv4.tcp_congestion_control=bbr" | tee -a /etc/sysctl.d/60-custom.conf

# Apply changes
sysctl -p /etc/sysctl.d/60-custom.conf

# Step 2: Find the main network interface
echo "Detecting main network interface..."
DEFAULT_INTERFACE=$(ip route | grep default | awk '{print $5}')

if [[ -z "$DEFAULT_INTERFACE" ]]; then
  echo "Error: Could not detect the main network interface. Exiting."
  exit 1
fi

echo "Detected network interface: $DEFAULT_INTERFACE"

# Step 3: Configure UFW NAT rules
echo "Configuring NAT (IP Masquerading)..."

# Backup UFW rules before modifying
cp /etc/ufw/before.rules /etc/ufw/before.rules.bak

# Insert NAT rules at the beginning of the file
sed -i "1i # NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n-A POSTROUTING -s 10.10.10.0/24 -o $DEFAULT_INTERFACE -j MASQUERADE\nCOMMIT\n" /etc/ufw/before.rules

# Step 4: Allow forwarding in UFW
echo "Allowing VPN traffic forwarding..."
sed -i "/# ok icmp code for FORWARD/a -A ufw-before-forward -s 10.10.10.0/24 -j ACCEPT\n-A ufw-before-forward -d 10.10.10.0/24 -j ACCEPT" /etc/ufw/before.rules

# Step 5: Restart UFW to apply changes
echo "Restarting UFW..."
systemctl restart ufw

# Step 6: Verify NAT rules
echo "Verifying NAT rules..."
iptables -t nat -L POSTROUTING

echo "NAT configuration completed successfully."
