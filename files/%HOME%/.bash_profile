[ -r ~/.bashrc ] && source ~/.bashrc

# start sway on login to tty1 if it's installed
if command -v sway >/dev/null 2>&1 && [ "$(tty)" = "/dev/tty1" ]; then
  export XDG_SESSION_TYPE=wayland
  export XDG_SESSION_DESKTOP=sway
  export XDG_CURRENT_DESKTOP=sway
  export GTK_USE_PORTAL=1
  export QT_QPA_PLATFORM=wayland
  export QT_QPA_PLATFORMTHEME=xdgdesktopportal
  exec sway
fi
