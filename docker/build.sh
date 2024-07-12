#!/bin/sh

set -x
set -e

DEV_PKGS="libc6-dev gcc python3-pip"

apt-get -y --no-install-recommends update -qq
apt-get -y --no-install-recommends install python-is-python3 nginx \
  ${DEV_PKGS}

python3 -m pip install --break-system-packages -U -r b2bua/requirements.txt

apt-get -y remove ${DEV_PKGS}
apt-get -y autoremove
apt-get -y clean

rm -rf ~/.cache
