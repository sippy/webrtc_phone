#!/bin/sh

set -x
set -e

DEV_PKGS="libc6-dev gcc"
NPM_RC="/usr/share/nodejs/npm/npmrc"

apt-get -y --no-install-recommends update -qq
apt-get -y --no-install-recommends install python-is-python3 python3-pip npm \
  libcap2-bin ${DEV_PKGS}

python3 -m pip install --break-system-packages -U -r b2bua/requirements.txt
npm install -g http-server

echo "logs-max=0" >> /usr/share/nodejs/npm/npmrc
echo "update-notifier=0" >> /usr/share/nodejs/npm/npmrc
echo "cache=/tmp/.npm_cache" >> /usr/share/nodejs/npm/npmrc
setcap 'cap_net_bind_service=+ep' /usr/bin/node

apt-get -y remove ${DEV_PKGS}
apt-get -y autoremove
apt-get -y clean

rm -rf ~/.cache
