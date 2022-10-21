#!/bin/bash

set -eux

apt-get -y autoremove --purge
apt-get -y clean
cloud-init clean

rm -rf /tmp/*
rm -rf /var/tmp/*

find /var/log/ -name *.log -exec rm -f {} \;
rm -f /root/.bash_history

dd if=/dev/zero of=/EMPTY bs=1M || true
rm -f /EMPTY

sync

# @TODO more cleanup probably
# https://github.com/DanHam/packer-virt-sysprep
# https://github.com/DanHam/packer-virt-sysprep-example
