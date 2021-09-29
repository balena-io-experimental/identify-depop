#!/bin/bash

BALENA_FLEET_AUTH_TOKEN=$1
BALENA_FLEET_ID=$2

if [ "$#" -ne 2 ]; then
  echo "Usage: ./scan.sh \$BALENA_FLEET_AUTH_TOKEN \$BALENA_FLEET_ID" >&2
  exit 1
fi

echo -e "Depop Profile Test Script (pca963x)\n"

# Check balena-cli is installed
for command in "balena" "jq" "curl"; do
    if ! [ -x "$(command -v $command)" ]; then
    echo 'Error: $command is not installed.' >&2
    exit 1
    fi
done

# Get all device UUIDs in fleet
> fleet.json && > suspect_devices.txt || true
curl -X GET \
"https://api.balena-cloud.com/v6/application(${BALENA_FLEET_ID})?\$expand=owns__device" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer ${BALENA_FLEET_AUTH_TOKEN}" \
-o fleet.json \
-s

# Write devices to text file
jq -r '.d | .[] | .owns__device[] | "\(.uuid) \(.is_online) \(.api_heartbeat_state)"' fleet.json > fleet_devices.txt

# Check if devices are online and have an api heartbeat
online_devices=()
while IFS= read -r line; do
  if [[ $line == *"true online"* ]]; then
    uuid=($line)
    online_devices+=(${uuid[0]})
  fi
done <fleet_devices.txt

# Check if device has pca963x RGB LED controller
> suspect_devices.txt || true
for device in ${online_devices[@]}; do
  echo UUID: $device, checking I2C...
  result=$(echo 'echo 0 > /sys/class/leds/pca963x\:blue/brightness; dmesg | grep "pca963x"; exit;' | balena ssh $device | tail -n +4)
  if [[ $result == *"failed"* ]]; then
    echo $device has missing I2C RGB driver
    echo $device >> suspect_devices.txt
  fi
done

# Cleanup
rm fleet.json fleet_devices.txt