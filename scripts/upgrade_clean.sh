#!/bin/bash

set -e

apt-get -y update && apt-get -y dist-upgrade
apt-get -y autoremove --purge
apt-get -y clean
cloud-init clean
