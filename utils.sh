#!/usr/bin/env bash
set -euo pipefail

# printing helpers

GREEN=$(tput setaf 2)
BLUE=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
ENDCOLOUR=$(tput sgr0)

function info() {
  echo "${BLUE}INFO:${ENDCOLOUR} $1"
}

function warn() {
  echo "${YELLOW}WARN:${ENDCOLOUR} $1"
}

function error() {
  echo "${RED}ERROR:${ENDCOLOUR} $1"
  exit 1
}

# util checks

echo jq | while read c; do
  if ! command -v $c >/dev/null 2>&1; then
    error "This utility depends on the '$c' command, which is not present."
  fi
done

# config helpers

function patch_config() {
  file="config-${1}.json"
  patch=$2

  if [ ! -f "${file}" ]; then
    error "Trying to patch '${file}' but it doesn't exist."
  fi

  if jq "${patch}" "${file}" > "${file}.tmp"; then
    if ! cmp -s "${file}" "${file}.tmp"; then
      # only print when we actually had a change
      info "Successfully patched '${file}'."
    fi
    mv "${file}.tmp" "${file}"
  else
    error "Failed to patch '${file}' - the file has not been changed. The attempted patch may have been written to '${file}.tmp'"
  fi
}

# check that we are being called from within the repo

call_dir=$(pwd)
repo_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

if [[ "${call_dir}" != "${repo_dir}" ]]; then
  error "This script must be called from within the repo directory (i.e. '${repo_dir}')"
fi

# set up config file if we didn't already

info "Bootstrapping config files..."

if [ ! -s config-global.json ]; then
  info "Creating inital global config file"
  echo '{}' > config-global.json
fi

if [ ! -s config-local.json ]; then
  info "Creating inital local config file"
  echo '{}' > config-local.json
fi

patch_config global '.files = if has("files") then .files else [] end'

patch_config local '.tags = if has("tags") then .tags else [] end'
