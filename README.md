[![Build Docker image](https://github.com/sippy/webrtc_phone/actions/workflows/build.yml/badge.svg)](https://github.com/sippy/webrtc_phone/actions/workflows/build.yml)

# What is it?

This is a technology demo integrating Sippy RTPProxy and Sippy B2BUA with
WebRTC-compatible clients. It includes four main components:

1. Sippy B2BUA.
2. Sippy RTPProxy.
3. SIP.js demo application.
4. Web server.

The container starts RTPProxy and B2BUA listening on WSS port `9876/TCP`, and
a web server on HTTPS port `443/TCP`. Both share the same self-signed TLS key
generated during the container build process. This allows users to open the
demo page and connect their browser to the B2BUA over WSS.

When the user initiates a call, the B2BUA/RTPProxy sets up two RTP sessions
(one encrypted and one plain) and initiates an outbound SIP call to the SIP
destination controlled by the `OUTBOUND_ROUTE` environment variable.

# Usage

```bash
docker pull sippylabs/webrtc_phone:latest
docker run -it --name webrtc_phone -P --network=host -e OUTBOUND_ROUTE="user@sip.mypbx.net;auth=foo:bar" -d sippylabs/webrtc_phone:latest
```

# Introspection

The container produces various SIP/RTP/WSS logs that can be inspected using
the `docker log` command. The amount of RTP logs can be controlled by the
`RTPP_LOG_LEVEL` environment variable. Possible values are `DBUG`, `INFO`,
`WARN`, `ERR`, and `CRIT` (in decreasing order of verbosity).

# Caveats and Limitations

- Connection to the WSS server will fail with error `1015` in Firefox. It
  works in Chrome and Microsoft Edge as long as the user accepts the security
  warning when opening the demo page. This is caused by the usage of the
  self-signed certificate.
- Only `Demo 1` works.
- Due to the need for a range of UDP ports for RTP sessions (2,000 by default),
  the usage of the `host` network is recommended.

# Links and References

- [RTPProxy @ GitHub](https://github.com/sippy/rtpproxy/)
- [Sippy B2BUA @ GitHub](https://github.com/sippy/b2bua/)
- [SIP.js @ GitHub](https://github.com/onsip/SIP.js/)
- [Sources for this container @ GitHub](https://github.com/sippy/webrtc_phone/)
