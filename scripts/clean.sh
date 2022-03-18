#!/bin/bash

set -e

apt-get -y autoremove --purge
apt-get -y clean
cloud-init clean

rm -rf /tmp/*
rm -rf /var/tmp/*

find /var/log/ -name *.log -exec rm -f {} \;
rm -f /root/.bash_history

# @TODO more cleanup probably
