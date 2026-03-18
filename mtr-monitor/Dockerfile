# https://developers.home-assistant.io/docs/add-ons/configuration#add-on-dockerfile
ARG BUILD_FROM
FROM $BUILD_FROM

ARG TEMPIO_VERSION BUILD_ARCH
RUN curl -sSLf -o /usr/bin/tempio \
    "https://github.com/home-assistant/tempio/releases/download/${TEMPIO_VERSION}/tempio_${BUILD_ARCH}"

# Install MTR and dependencies
RUN apk add --no-cache \
    mtr \
    python3 \
    py3-pip \
    bash \
    curl \
    jq \
    ca-certificates \
    mosquitto-clients

# Install Python dependencies
RUN pip install --no-cache-dir paho-mqtt requests

# Copy root filesystem
COPY rootfs /