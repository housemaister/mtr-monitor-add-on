ARG BUILD_FROM
FROM $BUILD_FROM

ARG TEMPIO_VERSION BUILD_ARCH
RUN curl -sSLf -o /usr/bin/tempio \
    "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}"

RUN apk add --no-cache mtr python3 py3-pip bash curl jq mosquitto-clients && \
    pip install --no-cache-dir paho-mqtt requests

COPY rootfs /