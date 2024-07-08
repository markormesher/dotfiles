#!/usr/bin/env bash
set -euo pipefail

### utils ###

GREEN=$(tput setaf 2)
BLUE=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
ENDCOLOUR=$(tput sgr0)

function okay() {
  echo "${GREEN}OKAY:${ENDCOLOUR} $1"
}

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

echo jq | while read c; do
  if ! command -v $c >/dev/null 2>&1; then
    error "This utility depends on the '$c' command, which is not present."
  fi
done

function patch_config() {
  file="config-${1}.json"
  patch=$2

  if [ ! -f "${file}" ]; then
    error "Trying to patch '${file}' but it doesn't exist."
  fi

  if jq "${patch}" "${file}" > "${file}.tmp"; then
    # only print when we actually had a change
    if ! cmp -s "${file}" "${file}.tmp"; then
      info "Successfully patched '${file}'."
    fi
    mv "${file}.tmp" "${file}"
  else
    error "Failed to patch '${file}' - the file has not been changed. The attempted patch may have been written to '${file}.tmp'"
  fi
}

function bootstrap_config() {
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
}

### track new files ###

function track_file() {
  bootstrap_config

  file="$1"

  if [ ! -f "${file}" ]; then
    echo "File '${file}' does not exist"
    exit 1
  fi

  orig_file_path=$(realpath -s "${file}")
  orig_file_path_to_store=$(sed "s#^${HOME}#%HOME%#" <<<"${orig_file_path}")

  repo_file_path_full="$(pwd)/files/${orig_file_path_to_store}"
  repo_file_path_relative="./files/${orig_file_path_to_store}"

  info "Tracking '${orig_file_path}' at '${repo_file_path_full}'."

  if [[ "$(jq -rc '.files | map(select(.original == "'"${orig_file_path_to_store}"'")) | length' config-global.json)" != "0" ]]; then
    error "The original file '${orig_file_path}' is already tracked in this repo."
  fi

  if [ -f "${repo_file_path_full}" ]; then
    error "The saved file '${repo_file_path_relative}' already exists in this repo."
  fi

  # copy into the repo
  mkdir -p "$(dirname "${repo_file_path_full}")"
  cp "${orig_file_path}" "${repo_file_path_full}"

  # create symlink
  rm "${orig_file_path}"
  ln -s "${repo_file_path_full}" "${orig_file_path}"

  # add to config
  patch_config global '.files += [{"original": "'"${orig_file_path_to_store}"'", "repo": "'"${repo_file_path_relative}"'"}]'
  patch_config global '.files = (.files | sort_by(.original))'
}

### untrack existing files ###

function untrack_file() {
  # TODO: this only affects the current host and creates broken symlinks on other hosts - need to think about handling this better

  bootstrap_config

  file="$1"

  orig_file_path=$(realpath -s "${file}")
  orig_file_path_to_store=$(sed "s#^${HOME}#%HOME%#" <<<"${orig_file_path}")

  info "Untracking '${orig_file_path}'."

  entry=$(jq -rc '.files | .[] | select(.original == "'"${orig_file_path_to_store}"'")' config-global.json)
  if [[ "${entry}" == "" ]]; then
    error "The original file '${orig_file_path}' is not tracked by this repo."
  fi

  repo_file=$(jq -rc '.repo' <<<"${entry}")

  if [ -f "${orig_file_path}" ]; then
    rm -f "${orig_file_path}"
    if [ -f "${repo_file}" ]; then
      cp "${repo_file}" "${orig_file_path}"
      info "Original file '${orig_file_path}' has been replaced with a static copy."
    else
      warn "Original file '${orig_file_path}' has NOT been replaced with a static copy because the saved file is missing."
    fi
  else
    info "Original file '${orig_file_path}' is not present on this machine, so it has NOT been replaced with a static copy."
  fi

  rm -f "${repo_file}"

  patch_config global '.files = (.files | map(select(.original != "'"${orig_file_path_to_store}"'")))'
}

### apply all files ###

function apply() {
  bootstrap_config

  jq -rc '.files | .[]' config-global.json | while read entry; do
    repo_path=$(jq -rc '.repo' <<<"${entry}")

    orig_path=$(jq -rc '.original' <<<"${entry}")
    orig_path=$(sed "s#%HOME%#${HOME}#" <<<"${orig_path}")

    repo_path_absolute=$(realpath "${repo_path}")
    if [[ -f "${orig_path}" ]]; then
      orig_path_absolute=$(realpath "${orig_path}")
    else
      orig_path_absolute=""
    fi

    if [[ "${orig_path_absolute}" == "${repo_path_absolute}" ]]; then
      okay "'${orig_path}' is already linked to the dotfiles repo."
    else
      rm -f "${orig_path}"
      mkdir -p "$(dirname "${orig_path}")"
      ln -s "${repo_path_absolute}" "${orig_path}"
      info "'${orig_path}' replaced with a symlink to the dotfiles repo."
    fi
  done
}

### entrypoint ###

# check that we are being called from within the repo

call_dir=$(pwd)
repo_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

if [[ "${call_dir}" != "${repo_dir}" ]]; then
  error "This script must be called from within the repo directory (i.e. '${repo_dir}')"
fi

cmd="${1:-}"
case "${cmd}" in
  track)
    shift 1
    for file in "$@"; do
      track_file "${file}"
    done
    ;;

  untrack)
    shift 1
    for file in "$@"; do
      untrack_file "${file}"
    done
    ;;

  apply)
    apply
    ;;

  *)
    echo "No valid command specified!"
    echo ""
    echo "Track new files:         ./dotfiles.sh track file1 ... fileN"
    echo "Untrack existing files:  ./dotfiles.sh untrack file1 ... fileN"
    echo "Apply all tracked files: ./dotfiles.sh apply"
    exit 1
    ;;
esac
