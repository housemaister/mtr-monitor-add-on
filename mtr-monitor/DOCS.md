# Home Assistant Add-on: MTR Connection Monitor

Monitor your internet connection health using MTR (My Traceroute) in Home Assistant.

## Features

- 🌐 Real-time internet connection monitoring
- 📊 Automatic sensor creation in Home Assistant
- 🔔 MQTT integration for flexible automation
- ⚙️ Fully configurable via Home Assistant options
- 📈 Perfect for dashboards and automations

## Configuration

### Options

- **target_host** (string): Host to monitor (default: `8.8.8.8`)
- **ping_interval** (integer): Seconds between checks (default: `300`, min: `60`, max: `3600`)
- **mtr_count** (integer): Packets per MTR run (default: `10`, min: `5`, max: `20`)
- **mqtt_enabled** (boolean): Publish to MQTT (default: `true`)
- **mqtt_broker** (string): MQTT broker address (default: `core-mosquitto`)
- **mqtt_prefix** (string): MQTT topic prefix (default: `homeassistant/sensor/mtr`)
- **log_level** (string): Log verbosity (default: `info`)

### Example Configuration

```yaml
target_host: 1.1.1.1
ping_interval: 600
mtr_count: 15
mqtt_enabled: true
mqtt_broker: core-mosquitto
mqtt_prefix: homeassistant/sensor/mtr
log_level: info