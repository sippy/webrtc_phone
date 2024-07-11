#!/bin/sh

set -x
set -e

sudo apt-get -y update -qq
sudo apt-get -y install npm

SJDIR="docker/SIP.js"

git -C "${SJDIR}" apply "`pwd`/patches/SIP.js.diff"
cd "docker/SIP.js/demo"
npm install
npm run build-demo
cd -

openssl req -newkey rsa:2048 -nodes -keyout docker/server.key -x509 -days 365 \
 -out docker/server.crt -config conf/openssl.cnf
