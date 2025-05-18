#!/usr/bin/bash

set -e
set -x

RTPP_LOG_LEVEL="${RTPP_LOG_LEVEL:-"info"}"
RTPP_NODEBUG="${RTPP_NODEBUG:-0}"

CFILE="${WRP_ROOT}/server.crt"
KFILE="${WRP_ROOT}/server.key"
WROOT="${WRP_ROOT}/SIP.js/demo"
HTTPS_PORT="${HTTPS_PORT:-"443"}"
WSS_PORT="${WSS_PORT:-"9876"}"
MIN_RTP_PORT="${MIN_RTP_PORT:-"32000"}"
MAX_RTP_PORT="${MAX_RTP_PORT:-"34000"}"
USE_RTP_IO="${USE_RTP_IO:-"1"}"

RSOCK="/tmp/rtpproxy.sock"
RMODDIR="/usr/local/lib/rtpproxy"

BDIR="${WRP_ROOT}/b2bua"

if [ -z "${OUTBOUND_ROUTE}" ]
then
  if [ ! -z "${OUTBOUND_PROXY}" ]
  then
    OUTBOUND_ROUTE="${OUTBOUND_PROXY}"
  else
    echo "Either OUTBOUND_ROUTE or OUTBOUND_PROXY needs to be set." >&2
    exit 1
  fi
fi

npm exec -- http-server -S -C "${CFILE}" -K "${KFILE}" -p ${HTTPS_PORT} "${WROOT}" &
HSERV_PID="${!}"

if [ ${RTPP_NODEBUG} -eq 0 ]
then
  RTPP_SUXX="_debug"
fi

if [ ${USE_RTP_IO} -eq 0 ]
then
 /usr/local/bin/rtpproxy${RTPP_SUXX} -f -F -s "${RSOCK}" \
  --dso "${RMODDIR}/rtpp_ice_lite${RTPP_SUXX}.so" \
  --dso "${RMODDIR}/rtpp_dtls_gw${RTPP_SUXX}.so" \
  -d "${RTPP_LOG_LEVEL}" -m "${MIN_RTP_PORT}" -M "${MAX_RTP_PORT}" &
 RTPP_PID="${!}"
 B2BUA_RSOCK="${RSOCK}"
else
 B2BUA_RSOCK="rtp.io:modules=ice_lite+dtls_gw;-d;${RTPP_LOG_LEVEL};-m;${MIN_RTP_PORT};-M;${MAX_RTP_PORT}"
fi

B2BUA_ARGS="--auth_enable=off --acct_enable=off --static_route=${OUTBOUND_ROUTE} \
 -f --b2bua_socket=/tmp/b2b.sock --rtp_proxy_client="${B2BUA_RSOCK}" --accept_ips=[[WSS]],[[PROXY]] \
 --allowed_pts=[G722/8000],[PCMU/8000],[PCMA/8000],[telephone-event/8000],[VP8/90000] \
 --wss_socket=0.0.0.0:${WSS_PORT}:${CFILE}:${KFILE}"

if [ ! -z "${OUTBOUND_PROXY}" ]
then
  B2BUA_ARGS="${B2BUA_ARGS} --sip_proxy=${OUTBOUND_PROXY}"
fi

PYTHONPATH="${BDIR}" python "${BDIR}/sippy/b2bua.py" \
 ${B2BUA_ARGS} &
B2B_PID="${!}"

wait -n
