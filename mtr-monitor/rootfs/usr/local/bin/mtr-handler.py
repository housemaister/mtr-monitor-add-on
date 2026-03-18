#!/usr/bin/env python3
"""
MTR Monitor Handler - Publishes metrics to Home Assistant via MQTT
"""

import argparse
import json
import requests
from datetime import datetime

try:
    import paho.mqtt.client as mqtt
except ImportError:
    mqtt = None

def publish_to_mqtt(broker, prefix, metrics):
    """Publish metrics to MQTT broker"""
    if mqtt is None:
        print("[ERROR] paho-mqtt not installed")
        return False
    
    try:
        client = mqtt.Client()
        client.connect(broker, 1883, 60)
        
        for key, value in metrics.items():
            topic = f"{prefix}/{key}"
            client.publish(topic, str(value), retain=True)
            print(f"[INFO] Published {topic} = {value}")
        
        client.disconnect()
        return True
    except Exception as e:
        print(f"[ERROR] MQTT publish failed: {e}")
        return False

def publish_to_ha_rest(metrics, target):
    """Publish metrics via Home Assistant REST API"""
    try:
        # Get Home Assistant token from environment
        ha_token = open('/data/ha_token.txt', 'r').read().strip()
        ha_url = "http://supervisor/core/api"
        
        headers = {
            "Authorization": f"Bearer {ha_token}",
            "content-type": "application/json",
        }
        
        for key, value in metrics.items():
            entity_id = f"sensor.mtr_{key}"
            
            # Create/update sensor via Home Assistant
            payload = {
                "entity_id": entity_id,
                "state": str(value),
                "attributes": {
                    "unit_of_measurement": "ms" if "latency" in key else "%",
                    "target": target,
                    "timestamp": datetime.now().isoformat()
                }
            }
            
            response = requests.post(
                f"{ha_url}/states/{entity_id}",
                headers=headers,
                json=payload
            )
            
            if response.status_code in [200, 201]:
                print(f"[INFO] Updated {entity_id} = {value}")
            else:
                print(f"[WARNING] Failed to update {entity_id}: {response.status_code}")
        
        return True
    except Exception as e:
        print(f"[WARNING] Home Assistant REST API not available: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='MTR Monitor Handler')
    parser.add_argument('--target', required=True)
    parser.add_argument('--avg-latency', required=True, type=float)
    parser.add_argument('--packet-loss', required=True, type=float)
    parser.add_argument('--best-latency', required=True, type=float)
    parser.add_argument('--worst-latency', required=True, type=float)
    parser.add_argument('--mqtt-enabled', required=True, type=lambda x: x.lower() == 'true')
    parser.add_argument('--mqtt-broker', required=True)
    parser.add_argument('--mqtt-prefix', required=True)
    
    args = parser.parse_args()
    
    metrics = {
        'avg_latency': args.avg_latency,
        'packet_loss': args.packet_loss,
        'best_latency': args.best_latency,
        'worst_latency': args.worst_latency,
    }
    
    print(f"[INFO] Processing metrics for target: {args.target}")
    
    # Try MQTT first if enabled
    if args.mqtt_enabled:
        publish_to_mqtt(args.mqtt_broker, args.mqtt_prefix, metrics)
    
    # Also try Home Assistant REST API
    publish_to_ha_rest(metrics, args.target)

if __name__ == '__main__':
    main()