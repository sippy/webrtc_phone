# syntax=docker/dockerfile:1.7-labs

ARG BASE_IMAGE="sippylabs/rtpproxy:latest"
FROM --platform=$TARGETPLATFORM $BASE_IMAGE AS build
LABEL maintainer="Maksym Sobolyev <sobomax@sippysoft.com>"

USER root

# Set Environment Variables
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp
COPY docker/build.sh docker/b2bua/requirements.txt /tmp

# Build & install everything
RUN ./build.sh

ENV WRP_ROOT="/webrtc_phone"
WORKDIR ${WRP_ROOT}
COPY --exclude=.git* --exclude=*.ts --link docker/SIP.js/demo \
 ${WRP_ROOT}/SIP.js/demo
COPY --exclude=.git --exclude=.github --link docker/b2bua ${WRP_ROOT}/b2bua
COPY docker/server.crt docker/server.key docker/run.sh ${WRP_ROOT}
RUN chown root:nogroup server.crt server.key && \
 chmod 640 server.crt server.key
USER nobody

ENV HTTPS_PORT=443
ENV WSS_PORT=9876

EXPOSE ${HTTPS_PORT}
EXPOSE ${WSS_PORT}
EXPOSE 32000-34000/udp

ENTRYPOINT [ "./run.sh" ]
