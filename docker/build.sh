#!/bin/sh

set -x
set -e

DEV_PKGS="libc6-dev gcc git make python3-dev"
PYTHON_CMD="python3"
PIP_I_CMD="${PYTHON_CMD} -m pip install --break-system-packages -U"
RTP_IO_VER="5c282725aeb"
WHEEL_D="/root/.cache/pip/wheels/${RTP_IO_VER}"
PIP_W_CMD="${PYTHON_CMD} -m pip wheel --wheel-dir=${WHEEL_D}"

build_depends() {
  apt-get -y --no-install-recommends update -qq
  apt-get -y --no-install-recommends install python-is-python3 python3-pip \
    libcap2-bin ${DEV_PKGS}
}

build_wheels() {
  if [ ! -e "${WHEEL_D}/"rtpproxy-*.whl ]
  then
    rm -rf "/root/.cache/pip"
    mkdir -p "${WHEEL_D}"
    ${PIP_W_CMD} git+https://github.com/sippy/py-rtpproxy.git@${RTP_IO_VER}
  fi
  ${PIP_I_CMD} "${WHEEL_D}/"rtpproxy-*.whl
}

get_py_bin() {
  PY_BIN="`which "${1}"`"
  while readlink "${PY_BIN}" > /dev/null
  do
    PY_BIN="`readlink "${PY_BIN}"`"
    PY_BIN="`which "${PY_BIN}"`"
  done
  echo "${PY_BIN}"
}

build_requirements() {
  ${PIP_I_CMD} -r requirements.txt

  setcap 'cap_net_bind_service=+ep' "`get_py_bin ${PYTHON_CMD}`"

  apt-get -y remove --purge ${DEV_PKGS}
  apt-get -y autoremove --purge
  apt-get -y clean

  mv /root/.cache/pip /root/cache_pip
  rm -rf ~/.cache
  mkdir -p /root/.cache
  mv /root/cache_pip /root/.cache/pip
}

for i in depends requirements wheels
do
  echo $i
  case ${1} in
  ${i})
    build_${i} "${@}"
    exit
    ;;
  esac
done
echo "Usage: `basename ${0}` {depends | requirements | wheels}" >&2
exit 1
