[![Build Docker image](https://github.com/sippy/webrtc_phone/actions/workflows/build.yml/badge.svg)](https://github.com/sippy/webrtc_phone/actions/workflows/build.yml)

# Sippy WebRTC Phone

## What is it?

This is a technology demo integrating Sippy RTPProxy and Sippy B2BUA with
WebRTC-compatible clients. It includes four main components:

1. Sippy B2BUA.
2. Sippy RTPProxy.
3. SIP.js demo application.
4. Web server.

## How it works

The container starts RTPProxy and B2BUA listening on WSS port `9876/TCP`, and
a web server on HTTPS port `443/TCP`. Both share the same self-signed TLS key
generated during the container build process. This allows users to open the
demo page and connect their browser to the B2BUA over WSS.

The only role of the HTTPS server is to allow user to download HTML/JS, it has
no role in the actual real-time session so that particular component can be
externalized.

Any registation attempts coming via the WSS socker are proxied to the external
SIP registrar controlled by the `OUTBOUND_PROXY` environment variable via
`SIP/UDP`.

When the user initiates a call, the B2BUA/RTPProxy sets up two RTP sessions
(one encrypted and one plain) and initiates an outbound SIP call to the SIP
destination controlled by the `OUTBOUND_ROUTE` environment variable. See
[Call Routing](https://github.com/sippy/b2bua/blob/master/documentation/documentation.md#call-routing)
section of the Sippy B2BUA documentation for this parameter format.

When no `OUTBOUND_ROUTE` is provided, `OUTBOUND_PROXY` will be used instead
as the only route to attempt.

## Usage

```bash
docker pull sippylabs/webrtc_phone:latest
docker run -it --name webrtc_phone -P --network=host \
 -e OUTBOUND_PROXY="sip.mypbx.net" -d sippylabs/webrtc_phone:latest
```

## Introspection

The container produces various SIP/RTP/WSS logs that can be inspected using
the `docker logs` command. The amount of RTP logs can be controlled by the
`RTPP_LOG_LEVEL` environment variable. Possible values are `DBUG`, `INFO`,
`WARN`, `ERR`, and `CRIT` (in decreasing order of verbosity).

## Performance

With the current configuration a single container should be able to support
up to 500 concurrent users fully utilizing up to 5-6 cores. If you try to
use it in a performance-critical scenario make sure to supply `RTPP_NODEBUG=1`
when running the container.

Specific range of UDP ports allocated by the RTPProxy can be controlled
by the `MIN_RTP_PORT` and `MAX_RTP_PORT` parameters. At this moment each
session allocates 4 ports, so that the range should be at least expected
maximum number of simultaneous sessions times 4.

## Caveats and Limitations

- Connection to the WSS server will fail with error `1015` in Firefox. It
  works in Chrome and Microsoft Edge as long as the user accepts the security
  warning when opening the demo page. This is caused by the usage of the
  self-signed certificate.
- Only `Demo 1` and `Demo 2` works.
- Due to the need for a range of UDP ports for RTP sessions (2,000 by default),
  the usage of the `host` network is recommended.

## Links and References

- [RTPProxy @ GitHub](https://github.com/sippy/rtpproxy/)
- [Sippy B2BUA @ GitHub](https://github.com/sippy/b2bua/)
- [SIP.js @ GitHub](https://github.com/onsip/SIP.js/)
- [Sources for this container @ GitHub](https://github.com/sippy/webrtc_phone/)
