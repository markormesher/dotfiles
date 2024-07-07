#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
source "${repo_dir}/utils.sh"

# copy to new path
# add to config
# replace with symlink to here

if [ "$#" -ne 1 ]; then
  echo "Usage: ./track-file.sh FILE"
  exit 1
fi

file="$1"

if [ ! -f "${file}" ]; then
  echo "File '${file}' does not exist"
  exit 1
fi

# decide where to put the file in this repo

orig_file_path=$(realpath -s "${file}")
repo_file_path_full="$(pwd)/files${orig_file_path}"
repo_file_path_relative="./files${orig_file_path}"

info "Tracking '${orig_file_path}' at '${repo_file_path_full}'."

if [[ "$(jq '.files | map(select(.original == "'"${orig_file_path}"'")) | length' config-global.json)" != "0" ]]; then
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

orig_file_path=$(sed "s#^${HOME}#\${HOME}#" <<<"${orig_file_path}")
patch_config global '.files += [{"original": "'"${orig_file_path}"'", "repo": "'"${repo_file_path_relative}"'"}]'
