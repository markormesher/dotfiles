#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
source "${repo_dir}/utils.sh"

jq -rc '.files | .[]' config-global.json | while read entry; do
  orig_path=$(jq -rc '.original' <<<"${entry}")
  repo_path=$(jq -rc '.repo' <<<"${entry}")

  # update HOME component
  orig_path=$(sed "s#\${HOME}#${HOME}#" <<<"${orig_path}")

  # get the real paths of both files and check whether they match already
  orig_path_real=$(realpath "${orig_path}")
  repo_path_real=$(realpath "${repo_path}")

  if [[ "${orig_path_real}" == "${repo_path_real}" ]]; then
    info "'${orig_path}' is already linked to the dotfiles repo - nothing to do."
  else
    info "Replacing '${orig_path}' with a symlink to the dotfiles repo."
    rm "${orig_path}"
    ln -s "${repo_path_real}" "${orig_path}"
  fi
done
