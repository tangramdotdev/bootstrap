#!/bin/bash
set -euo pipefail

pushd /etc/sysconfig
log "Creating /etc/sysconfig/ifconfig.eth0..."
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.1.2
GATEWAY=192.168.1.1
PREFIX=24
BROADCAST=192.168.1.255
EOF
popd

log "Creating /etc/resolv.conf..."
cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

nameserver 8.8.8.8
nameserver 8.8.4.4

# End /etc/resolv.conf
EOF

log "Creating /etc/hostname..."
echo "bootstrap" > /etc/hostname

log "Creating /etc/hosts..."
cat > /etc/hosts << "EOF"
# Begin /etc/hosts

127.0.0.1 localhost.localdomain localhost
127.0.0.2 bootstrap
::1       localhost ip6-localhost ip6-loopback
ff02::1   ip6-allnodes
ff02::2   ip6-allrouters

# End /etc/hosts
EOF
