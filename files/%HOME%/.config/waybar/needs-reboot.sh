#!/usr/bin/env bash
set -euo pipefail

function real_cmd() {
  cmd=$1
  if ! which $cmd >/dev/null 2>&1; then
    exit 1
  else
    which $cmd
  fi
}

pacman=$(real_cmd pacman)
systemctl=$(real_cmd systemctl)
uname=$(real_cmd uname)

needs_reboot=0

installed_linux=$($pacman -Q linux | cut -d " " -f 2 | sed 's/[\.\-]/_/g')
running_linux=$($uname -r | sed 's/[\.\-]/_/g')
if [[ "${running_linux}" != "${installed_linux}" ]]; then
  needs_reboot=1
fi

installed_systemd=$($pacman -Q systemd | cut -d " " -f 2 | sed 's/[\.\-]/_/g')
running_systemd=$($systemctl --version | sed 's/[\.\-]/_/g')
if [[ "${running_systemd}" != *"${installed_systemd}"* ]]; then
  needs_reboot=1
fi

if [[ ${needs_reboot} == 0 ]]; then
  echo -n '{"text":""}'
else
  echo -n '{"text":"Reboot soon!","class":"yes"}'
fi
