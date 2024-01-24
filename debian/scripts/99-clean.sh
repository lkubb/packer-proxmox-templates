#!/bin/bash

set -eux

apt-get -y autoremove --purge
apt-get -y clean
cloud-init clean

rm -rf /tmp/*
rm -rf /var/tmp/*

find /var/log/ -name *.log -exec rm -f {} \;
rm -f /root/.bash_history
# Replace DNS config from DHCP with something generic.
# You will need to manage this file somehow on its children.
# For stock Debian Server and ifupdown, you'll need resolvconf
# or do something with cloud-init.
cat << EOF > /etc/resolv.conf
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

# Try to disable dhclient from running by default,
# it does this even if the configuration is overridden
sed -i 's/dhcp/manual/' /etc/network/interfaces

dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY

sync

# @TODO more cleanup probably
# https://github.com/DanHam/packer-virt-sysprep
# https://github.com/DanHam/packer-virt-sysprep-example
