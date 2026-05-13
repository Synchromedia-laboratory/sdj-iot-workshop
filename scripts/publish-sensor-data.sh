#!/bin/sh
set -eu

ROUNDS="${1:-10}"
HOST="${MQTT_HOST:-mqtt-broker}"
PORT="${MQTT_PORT:-1883}"

case "$ROUNDS" in
  ''|*[!0-9]*)
    echo "Usage: sh /usr/local/bin/publish-sensor-data [number_of_rounds]" >&2
    exit 1
    ;;
esac

i=1
while [ "$i" -le "$ROUNDS" ]; do
  temp=$((22 + i % 6))
  humidity=$((55 + i % 12))
  pressure=$((1010 + i % 9))

  mosquitto_pub -h "$HOST" -p "$PORT" -t temp -m "$temp"
  mosquitto_pub -h "$HOST" -p "$PORT" -t humidity -m "$humidity"
  mosquitto_pub -h "$HOST" -p "$PORT" -t pressure -m "$pressure"

  echo "Round $i/$ROUNDS: temp=$temp humidity=$humidity pressure=$pressure"
  i=$((i + 1))
  sleep 1
done
