#!/bin/sh

set -x
set -e

DEV_PKGS="libc6-dev gcc"

apt-get -y --no-install-recommends update -qq
apt-get -y --no-install-recommends install python-is-python3 python3-pip npm \
  ${DEV_PKGS}

python3 -m pip install --break-system-packages -U -r b2bua/requirements.txt
npm install http-server

apt-get -y remove ${DEV_PKGS}
apt-get -y autoremove
apt-get -y clean

rm -rf ~/.cache
