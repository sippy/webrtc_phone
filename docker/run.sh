#!/usr/bin/bash

set -e
set -x

OUTBOUND_ROUTE="${OUTBOUND_ROUTE:-"0100@192.168.23.52;auth=nopass"}"
RTPP_LOG_LEVEL="${RTPP_LOG_LEVEL:-"dbug"}"

CFILE="/webrtc_phone/server.crt"
KFILE="/webrtc_phone/server.key"
WROOT="/webrtc_phone/SIP.js/demo"
MIN_RTP_PORT=32000
MAX_RTP_PORT=34000

RSOCK="/webrtc_phone/rtpproxy.sock"
RMODDIR="/usr/local/lib/rtpproxy"

BDIR="/webrtc_phone/b2bua"

nginx -c /webrtc_phone/nginx.conf &
HSERV_PID="${!}"

/usr/local/bin/rtpproxy_debug -f -F -s "${RSOCK}" \
  --dso "${RMODDIR}/rtpp_ice_lite_debug.so" \
  --dso "${RMODDIR}/rtpp_dtls_gw_debug.so" \
  -d "${RTPP_LOG_LEVEL}" -m "${MIN_RTP_PORT}" -M "${MAX_RTP_PORT}" &
RTPP_PID="${!}"

PYTHONPATH="${BDIR}" python "${BDIR}/sippy/b2bua_radius.py" \
 --auth_enable=off --acct_enable=off --static_route="${OUTBOUND_ROUTE}" \
 -f --b2bua_socket=/tmp/b.sock --rtp_proxy_clients="${RSOCK}" \
 --allowed_pts=0,8,9,126,101 --wss_socket="0.0.0.0:9876:${CFILE}:${KFILE}" &
B2B_PID="${!}"

wait -n
