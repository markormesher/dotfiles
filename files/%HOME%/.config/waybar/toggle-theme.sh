#!/usr/bin/env bash
set -euo pipefail

GTK3_CONFIG="$HOME/.config/gtk-3.0/settings.ini"
mkdir -p "$(dirname "$GTK3_CONFIG")"

scheme=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ "$scheme" == *dark* ]]; then
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
  gsettings set org.gnome.desktop.interface icon-theme "Papirus-Light"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
  cat > "$GTK3_CONFIG" <<EOF
[Settings]
gtk-theme-name=Adwaita
gtk-application-prefer-dark-theme=0
EOF

  notify-send "Light mode"
else
  gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
  gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
  cat > "$GTK3_CONFIG" <<EOF
[Settings]
gtk-theme-name=Adwaita
gtk-application-prefer-dark-theme=1
EOF

  notify-send "Dark mode"
fi
