#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v podman-compose >/dev/null 2>&1; then
  COMPOSE="podman-compose"
else
  echo "Error: install Docker Compose or podman-compose before running this script." >&2
  exit 1
fi

echo "Starting IoT stack with: $COMPOSE"
$COMPOSE up -d

echo
echo "Stack is starting. Useful URLs:"
echo "- Grafana:  http://localhost:3000  admin/admin"
echo "- InfluxDB: http://localhost:8086"
echo "- MQTT:     localhost:1883"
echo
echo "Send a test value with:"
echo 'mosquitto_pub -h localhost -t temp -m "25"'
