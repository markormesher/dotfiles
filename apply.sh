#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
source "${repo_dir}/utils.sh"

jq -rc '.files | .[]' config-global.json | while read entry; do
  repo_path=$(jq -rc '.repo' <<<"${entry}")

  orig_path=$(jq -rc '.original' <<<"${entry}")
  orig_path=$(sed "s#%HOME%#${HOME}#" <<<"${orig_path}")

  repo_path_real=$(realpath "${repo_path}")
  if [[ -f "${orig_path}" ]]; then
    orig_path_real=$(realpath "${orig_path}")
  else
    orig_path_real=""
  fi

  if [[ "${orig_path_real}" == "${repo_path_real}" ]]; then
    okay "'${orig_path}' is already linked to the dotfiles repo."
  else
    rm -f "${orig_path}"
    mkdir -p "$(dirname "${orig_path}")"
    ln -s "${repo_path_real}" "${orig_path}"
    info "'${orig_path}' replaced with a symlink to the dotfiles repo."
  fi
done
