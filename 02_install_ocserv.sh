#!/bin/bash

# Step 1: Install build dependencies
echo "Installing dependencies for building OpenConnect..."
apt install -y libgnutls28-dev libev-dev libpam0g-dev liblz4-dev libseccomp-dev \
  libreadline-dev libnl-route-3-dev libkrb5-dev libradcli-dev \
  libcurl4-gnutls-dev libcjose-dev libjansson-dev libprotobuf-c-dev \
  libtalloc-dev libhttp-parser-dev protobuf-c-compiler gperf \
  nuttcp lcov libuid-wrapper libpam-wrapper libnss-wrapper \
  libsocket-wrapper gss-ntlmssp haproxy iputils-ping freeradius \
  gawk gnutls-bin iproute2 yajl-tools tcpdump autoconf automake ipcalc-ng

# Step 2: Clone the ocserv Git repository
echo "Cloning OpenConnect repository..."
git clone https://gitlab.com/openconnect/ocserv.git

# Step 3: Navigate to the cloned repository
cd ocserv

# Step 4: Generate configuration scripts
echo "Generating configuration scripts..."
autoreconf -fvi


sudo apt install ipcalc-ng
# Step 5: Configure and compile
echo "Configuring and compiling OpenConnect..."
./configure && make

# Step 6: Install ocserv
echo "Installing OpenConnect..."
make install

# Step 7: Copy ocserv binaries to the correct location
echo "Copying ocserv binaries..."
cd src
cp ocserv /usr/sbin
cp ocserv-worker /usr/sbin

# Step 8: Copy the systemd service file
echo "Setting up the ocserv systemd service..."
cp ../doc/systemd/standalone/ocserv.service /etc/systemd/system/ocserv.service

# Step 9: Update the systemd service file to point to the correct binary path
sed -i 's|ExecStart=/usr/sbin/ocserv|ExecStart=/usr/local/sbin/ocserv|' /etc/systemd/system/ocserv.service

# Step 10: Reload systemd daemon
echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "OpenConnect installation and setup completed."
