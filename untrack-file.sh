#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
source "${repo_dir}/utils.sh"

if [ "$#" -ne 1 ]; then
  echo "Usage: ./untrack-file.sh FILE"
  exit 1
fi

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
  info "Original file '${orig_file_path}' is not present on this machine, so it has not been replaced with a static copy."
fi

rm -f "${repo_file}"

patch_config global '.files = (.files | map(select(.original != "'"${orig_file_path_to_store}"'")))'
