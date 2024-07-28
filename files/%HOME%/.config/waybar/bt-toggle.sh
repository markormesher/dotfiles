#!/usr/bin/env bash
set -euo pipefail

if ! command -v bluetoothctl; then
  echo "bluetoothctl is not installed"
  exit 1
fi

if bluetoothctl show | grep "Powered: yes"; then
  bluetoothctl power off
else
  bluetoothctl power on
fi
