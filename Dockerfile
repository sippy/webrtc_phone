ARG BASE_IMAGE
FROM --platform=$TARGETPLATFORM $BASE_IMAGE as build
LABEL maintainer="Maksym Sobolyev <sobomax@sippysoft.com>"

USER root

# Set Environment Variables
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /webrtc_phone
COPY docker /webrtc_phone/

# Build & install everything
RUN /webrtc_phone/build.sh

EXPOSE 443
EXPOSE 9876
EXPOSE 32000-34000/udp

ENTRYPOINT [ "/webrtc_phone/run.sh" ]
