#!/usr/bin/env bash
set -euo pipefail

curr=$(gsettings get org.gnome.desktop.interface gtk-theme)
if [[ "$curr" == *dark* ]]; then
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
  notify-send "Light mode enabled" || false
else
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
  notify-send "Dark mode enabled" || false
fi
