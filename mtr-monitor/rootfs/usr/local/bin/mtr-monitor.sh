#!/bin/bash

# MTR Monitor - Internet Connection Health Monitoring
set -e

# Configuration
CONFIG_PATH=/data/options.json
TARGET_HOST=$(jq -r '.target_host // "8.8.8.8"' "$CONFIG_PATH")
PING_INTERVAL=$(jq -r '.ping_interval // 300' "$CONFIG_PATH")
MTR_COUNT=$(jq -r '.mtr_count // 10' "$CONFIG_PATH")
MQTT_ENABLED=$(jq -r '.mqtt_enabled // true' "$CONFIG_PATH")
MQTT_BROKER=$(jq -r '.mqtt_broker // "core-mosquitto"' "$CONFIG_PATH")
MQTT_PREFIX=$(jq -r '.mqtt_prefix // "homeassistant/sensor/mtr"' "$CONFIG_PATH")
LOG_LEVEL=$(jq -r '.log_level // "info"' "$CONFIG_PATH")

LOG_FILE="/data/mtr-monitor.log"

# Logging function
log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE"
    
    if [[ "$level" == "ERROR" ]] || [[ "$LOG_LEVEL" == "debug" ]]; then
        echo "[${timestamp}] [${level}] ${message}"
    fi
}

log "INFO" "MTR Monitor started - Target: $TARGET_HOST, Interval: ${PING_INTERVAL}s"

# Main monitoring loop
while true; do
    log "DEBUG" "Running MTR against $TARGET_HOST (${MTR_COUNT} packets)"
    
    # Run MTR and capture output
    MTR_OUTPUT=$(mtr -r -c "$MTR_COUNT" "$TARGET_HOST" 2>&1 || true)
    
    # Parse the last line (summary statistics)
    LAST_LINE=$(echo "$MTR_OUTPUT" | tail -n 1)
    
    log "DEBUG" "MTR Output: $LAST_LINE"
    
    # Extract metrics using awk
    # Format: hostname  Snt   Last   Avg  Best  Wrst Loss%
    PACKET_LOSS=$(echo "$LAST_LINE" | awk '{print $NF}' | tr -d '%')
    AVG_LATENCY=$(echo "$LAST_LINE" | awk '{print $6}')
    BEST_LATENCY=$(echo "$LAST_LINE" | awk '{print $5}')
    WORST_LATENCY=$(echo "$LAST_LINE" | awk '{print $7}')
    LAST_LATENCY=$(echo "$LAST_LINE" | awk '{print $4}')
    
    # Validate metrics
    if [[ ! -z "$AVG_LATENCY" && "$AVG_LATENCY" != "Avg" ]]; then
        log "INFO" "Metrics - Latency: ${AVG_LATENCY}ms, Loss: ${PACKET_LOSS}%"
        
        # Call Python handler to publish metrics
        /usr/local/bin/mtr-handler.py \
            --target "$TARGET_HOST" \
            --avg-latency "$AVG_LATENCY" \
            --packet-loss "$PACKET_LOSS" \
            --best-latency "$BEST_LATENCY" \
            --worst-latency "$WORST_LATENCY" \
            --mqtt-enabled "$MQTT_ENABLED" \
            --mqtt-broker "$MQTT_BROKER" \
            --mqtt-prefix "$MQTT_PREFIX" \
            2>&1 | tee -a "$LOG_FILE"
    else
        log "ERROR" "Failed to parse MTR output: $LAST_LINE"
    fi
    
    log "DEBUG" "Sleeping for ${PING_INTERVAL} seconds"
    sleep "$PING_INTERVAL"
done