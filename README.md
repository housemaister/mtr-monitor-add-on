# MTR Connection Monitor Add-on

Monitor your internet connection health using MTR (My Traceroute) in Home Assistant.

## Overview

This add-on runs periodic MTR diagnostics against a target host (default: Google DNS 8.8.8.8) and exposes the following metrics as Home Assistant sensors:

- **Average Latency** (ms)
- **Packet Loss** (%)
- **Best Latency** (ms)
- **Worst Latency** (ms)

## Features

- 🌐 Real-time internet connection monitoring
- 📊 Automatic sensor creation in Home Assistant
- 🔔 MQTT integration for flexible automation
- ⚙️ Fully configurable via Home Assistant options
- 📈 Perfect for dashboards and automations

## Installation

1. Add this repository to Home Assistant Add-ons
2. Install the MTR Connection Monitor add-on
3. Configure options (optional - defaults work great)
4. Start the add-on
5. Check the logs to verify it's working

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fhousemaister%2Fmtr-monitor-add-on)

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
```

## Usage

### Accessing Metrics

Once running, the add-on creates these MQTT topics:

```
homeassistant/sensor/mtr/avg_latency
homeassistant/sensor/mtr/packet_loss
homeassistant/sensor/mtr/best_latency
homeassistant/sensor/mtr/worst_latency
```

### Creating Sensors in Home Assistant

Add to your `configuration.yaml`:

```yaml
sensor:
  - platform: mqtt
    name: "Internet Average Latency"
    state_topic: "homeassistant/sensor/mtr/avg_latency"
    unit_of_measurement: "ms"
    icon: mdi:speedometer

  - platform: mqtt
    name: "Internet Packet Loss"
    state_topic: "homeassistant/sensor/mtr/packet_loss"
    unit_of_measurement: "%"
    icon: mdi:wifi-off
```

### Dashboard Example

Create a dashboard with a gauge for quick visual feedback:

```yaml
type: gauge
entity: sensor.internet_average_latency
name: Internet Latency
min: 0
max: 300
severity:
  green: 0
  yellow: 50
  red: 100
```

### Automations

Alert when latency is high:

```yaml
automation:
  - alias: "Notify High Internet Latency"
    trigger:
      platform: numeric_state
      entity_id: sensor.internet_packet_loss
      above: 5
    action:
      service: notify.mobile_app_your_device
      data:
        message: "Internet packet loss is above 5%!"
```

## Logs

View add-on logs at: `Supervisor > Add-ons > MTR Connection Monitor > Logs`

Or access the log file: `/data/mtr-monitor.log`

## Troubleshooting

**Sensors not appearing in Home Assistant:**
- Ensure MQTT add-on is running
- Check logs for errors
- Verify `mqtt_prefix` matches your Home Assistant configuration

**MTR not running:**
- Check available disk space
- Verify target host is accessible
- Check add-on logs for detailed errors

**High latency readings:**
- Try a different target host
- Check your network status
- Verify MTR output format is correct

## Support

For issues, questions, or contributions, please visit the [GitHub repository](https://github.com/housemaister/mtr-monitor-addon).

## License

MIT License