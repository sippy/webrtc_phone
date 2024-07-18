ARG BASE_IMAGE="sippylabs/rtpproxy:latest"
FROM --platform=$TARGETPLATFORM $BASE_IMAGE AS build
LABEL maintainer="Maksym Sobolyev <sobomax@sippysoft.com>"

USER root

# Set Environment Variables
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /webrtc_phone
COPY docker /webrtc_phone/

# Build & install everything
RUN /webrtc_phone/build.sh

ENV HTTPS_PORT=443
ENV WSS_PORT=9876

EXPOSE ${HTTPS_PORT}
EXPOSE ${WSS_PORT}
EXPOSE 32000-34000/udp

RUN chown root:nogroup server.crt server.key && \
 chmod 640 server.crt server.key
USER nobody

ENTRYPOINT [ "/webrtc_phone/run.sh" ]
