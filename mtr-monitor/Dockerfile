FROM alpine:latest

# Install required packages
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
RUN pip install --no-cache-dir \
    paho-mqtt \
    requests

# Copy app files
COPY rootfs/ /

# Make scripts executable
RUN chmod +x /usr/local/bin/mtr-monitor.sh \
    && chmod +x /usr/local/bin/mtr-handler.py \
    && chmod +x /etc/services.d/mtr-monitor/run

WORKDIR /app

