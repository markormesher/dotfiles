#!/usr/bin/env bash
set -euo pipefail

killall -q waybar || :
touch /tmp/waybar.log
echo "---" | tee -a /tmp/waybar.log
waybar 2>&1 | tee -a /tmp/waybay.log & disown
