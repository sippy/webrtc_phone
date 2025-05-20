# syntax=docker/dockerfile:1.7-labs

ARG BASE_IMAGE="sippylabs/rtpproxy:latest"
ARG PIP_CACHE_IMAGE="scratch"

FROM --platform=$TARGETPLATFORM ${PIP_CACHE_IMAGE} AS pipcache
FROM --platform=$TARGETPLATFORM $BASE_IMAGE AS build
LABEL maintainer="Maksym Sobolyev <sobomax@sippysoft.com>"

USER root

# Set Environment Variables
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

# Build & install everything
ARG TARGETPLATFORM
ENV SET_ENV="sh /tmp/docker/set_env.sh platformopts"

RUN --mount=type=bind,source=docker/build.sh,target=build.sh \
    --mount=type=bind,source=docker/b2bua/docker/set_env.sh,target=docker/set_env.sh \
     env -S "`${SET_ENV}`" ./build.sh depends

RUN mkdir -p /root/.cache/pip
RUN --mount=type=bind,from=pipcache,source=/,target=/pip_cache_root,readonly \
 test ! -d /pip_cache_root/root/.cache/pip || \
  cp -a /pip_cache_root/root/.cache/pip /root/.cache/
RUN rm -rf /pip_cache_root

RUN --mount=type=bind,source=docker/build.sh,target=build.sh \
    --mount=type=bind,source=docker/b2bua/docker/set_env.sh,target=docker/set_env.sh \
     env -S "`${SET_ENV}`" ./build.sh wheels

RUN --mount=type=bind,source=docker/build.sh,target=build.sh \
    --mount=type=bind,source=docker/b2bua/requirements.txt,target=requirements.txt \
    --mount=type=bind,source=docker/b2bua/docker/set_env.sh,target=docker/set_env.sh \
     env -S "`${SET_ENV}`" ./build.sh requirements

ENV WRP_ROOT="/webrtc_phone"
WORKDIR ${WRP_ROOT}
COPY --exclude=.git* --exclude=*.ts docker/SIP.js/demo \
 ${WRP_ROOT}/SIP.js/demo
COPY --exclude=.git --exclude=.github docker/b2bua ${WRP_ROOT}/b2bua
COPY UI ${WRP_ROOT}/UI
COPY docker/SIP.js/demo/dist/demo-1.js ${WRP_ROOT}/UI/static/webrtc_phone.js
COPY docker/server.crt docker/server.key docker/run.sh ${WRP_ROOT}
RUN chown root:nogroup server.crt server.key && \
 chmod 640 server.crt server.key
USER nobody

ENV HTTPS_PORT=443
ENV WSS_PORT=9876

ENV MIN_RTP_PORT=32000
ENV MAX_RTP_PORT=34000

EXPOSE ${HTTPS_PORT}
EXPOSE ${WSS_PORT}
EXPOSE ${MIN_RTP_PORT}-${MAX_RTP_PORT}/udp

ENTRYPOINT [ "./run.sh" ]
