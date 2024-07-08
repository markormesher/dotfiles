[ -r ~/.bashrc ] && source ~/.bashrc

# start sway on login to tty1 if it's installed
command -v sway >/dev/null 2>&1 && [ "$(tty)" = "/dev/tty1" ] && exec sway
