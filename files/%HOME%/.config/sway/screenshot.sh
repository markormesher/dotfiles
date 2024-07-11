#!/usr/bin/env bash
set -euo pipefail

if ! command -v grim >/dev/null 2>&1; then
  notify-send -t 1000 "Can't screenshot - grim is not installed"
  exit 1
fi

if ! command -v slurp >/dev/null 2>&1; then
  notify-send -t 1000 "Can't screenshot - slurp is not installed"
  exit 1
fi

slurp | grim -g - $(xdg-user-dir PICTURES)/$(date +'screenshot_%Y-%m-%d-%H%M%S.png')
