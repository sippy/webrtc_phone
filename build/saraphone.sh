#!/bin/sh

set -x
set -e

SPDIR="docker/SIP.js/demo/saraphone"

git -C "${SPDIR}" apply "`pwd`/patches/saraphone.diff"
