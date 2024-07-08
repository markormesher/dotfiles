#! /usr/bin/env bash
#set -euo pipefail

# Interactive shells only
[[ $- == *i* ]] || return

#######################
# Utils for this file #
#######################

TXT_BOLD="$(tput bold)"
TXT_BLACK="$(tput setaf 0)"
TXT_RED="$(tput setaf 1)"
TXT_GREEN="$(tput setaf 2)"
TXT_YELLOW="$(tput setaf 3)"
TXT_MAGENTA="$(tput setaf 5)"
TXT_CYAN="$(tput setaf 6)"
TXT_RESET="$(tput sgr0)"

function warn {
  echo "${TXT_RED}Warning:${TXT_RESET} ${1}"
}

####################
# $PATH management #
####################

PATH=""

# core (more specific first to catch things like Brew packages)
[ -d "/usr/local/go/bin" ] && PATH="${PATH}:/usr/local/go/bin"
[ -d "/opt/homebrew/bin" ] && PATH="${PATH}:/opt/homebrew/bin"
PATH="${PATH}:/usr/local/sbin"
PATH="${PATH}:/usr/local/bin"
PATH="${PATH}:/usr/sbin"
PATH="${PATH}:/usr/bin"
PATH="${PATH}:/sbin"
PATH="${PATH}:/bin"

# user-owned binaries
[ -d "${HOME}/go/bin" ] && PATH="${PATH}:${HOME}/go/bin"
[ -d "${HOME}/bin" ] && PATH="${PATH}:${HOME}/bin"

# ubuntu snap
[ -d "/snap/bin" ] && PATH="${PATH}:/snap/bin"

# node
[ -d "${HOME}/.npm-packages/bin" ] && PATH="${PATH}:${HOME}/.npm-packages/bin"

export PATH

##############
# Mac things #
##############

DEFAULT_BREW_PACKAGES=(
  # keep this sorted
  "bash-completion"
  "colordiff"
  "coreutils"
  "fd"
  "findutils"
  "font-hack-nerd-font"
  "gawk"
  "git"
  "gnu-getopt"
  "gnu-indent"
  "gnu-sed"
  "gnu-tar"
  "gnutls"
  "grep"
  "htop"
  "jq"
  "neovim"
  "node"
  "ripgrep"
  "tmux"
  "wget"
  "yadm"
)

function running_on_mac {
  [[ "$(uname -s)" == "Darwin" ]]
}

function check_brew {
  running_on_mac && command -v brew &> /dev/null
}

function get_missing_brew_packages {
  touch "${HOME}/.last-brew-list"
  comm -13 <(cat "${HOME}/.last-brew-list") <(printf '%s\n' "${DEFAULT_BREW_PACKAGES[@]}")
}

function check_brew_packages {
  if running_on_mac; then
    if ! check_brew; then
      warn "You're running on Mac without Brew installed - check out https://brew.sh/"
    elif (get_missing_brew_packages | grep . &> /dev/null); then
      warn "One or more default Brew packages are not installed - run install_brew_packages to get them"
      get_missing_brew_packages
    fi
  fi
}

function install_brew_packages {
  get_missing_brew_packages | while read -r package; do brew install "${package}"; done
  brew list | sort > "${HOME}/.last-brew-list"
}

check_brew_packages

#####################
# Core Bash options #
#####################

# Don't put duplicate lines or lines starting with space in the history
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# Reasonable history size
HISTSIZE=1000
HISTFILESIZE=2000

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Better tab completion
[ -f /etc/bash_completion ] && source /etc/bash_completion
if check_brew && [ -f "$(brew --prefix)/etc/bash_completion" ]; then
  source "$(brew --prefix)/etc/bash_completion"
fi

#################
# Custom prompt #
#################

function git_info_for_prompt() {
  if git rev-parse 2> /dev/null; then
    branch_colour=$(git config user.email | grep markormesher > /dev/null 2>&1  && echo -n "$TXT_YELLOW" || echo -n "$TXT_RED")
    echo -ne "[ ${branch_colour}⌥ $(git rev-parse --abbrev-ref HEAD 2> /dev/null)${TXT_RESET} ]"
  else
    echo -ne ""
  fi
}

function shortened_dir() {
  dirs +0 | awk -F '/' '{ for(i=1;i<NF;i++) { printf(substr($i, 1, 1)); printf "/" }; printf $NF }'
}

function custom_prompt() {
  if [ "$USER" = "root" ]; then
    local user_and_host="[ ${TXT_RED}${TXT_BOLD}\u${TXT_RESET}${TXT_GREEN}${TXT_BOLD}@\h${TXT_RESET} ]"
  else
    local user_and_host="[ ${TXT_GREEN}${TXT_BOLD}\u@\h${TXT_RESET} ]"
  fi

  local cwd="[ ${TXT_CYAN}\$(shortened_dir)${TXT_RESET} ]"

  local prompt="$ "
  export PS1="\n┌─${user_and_host}${cwd}\$(git_info_for_prompt)\n└───$prompt"
}

custom_prompt

# direnv hook needs to be after any custom prompt work
if command -v direnv &> /dev/null; then
  eval "$(direnv hook bash)"
fi

###################################
# Per-service exports and aliases #
###################################

# bash

alias ..='cd ..'
alias cp='rsync -avz --progress'
alias sum="paste -sd+ - | bc"

if command -v apt &> /dev/null; then
  alias apt='sudo apt'
fi

# use the GNU versions of tools where possible (requires some brew packages)
if running_on_mac; then
  if check_brew && ! (cat "${HOME}/.last-brew-list" | grep coreutils > /dev/null); then
    warn "GNU utils are not installed - some parts of .bashrc may not work correctly"
    echo "Run install_brew_packages to install the missing packages"
  else
    alias awk='gawk'
    alias date='gdate'
    alias df='gdf'
    alias du='gdu'
    alias find='gfind'
    alias head='ghead'
    alias readlink='greadlink'
    alias sed='gsed'
    alias shuf='gshuf'
    alias split='gsplit'
    alias stat='gstat'
    alias tail='gtail'
    alias tar='gtar'
    alias xargs='gxargs'
  fi

  export CLICOLOR=1
  export LSCOLORS=GxFxCxDxBxegedabagaced
  export BASH_SILENCE_DEPRECATION_WARNING=1
fi

if running_on_mac; then
  alias l='gls --color=auto -h --group-directories-first'
  alias ls='gls --color=auto -h --group-directories-first'
  alias ll='gls -la --color=auto -h --group-directories-first'
else
  alias l='ls --color=auto -h --group-directories-first'
  alias ls='ls --color=auto -h --group-directories-first'
  alias ll='ls -la --color=auto -h --group-directories-first'
fi

if running_on_mac; then
  alias grep='ggrep --color=auto'
  alias egrep='gegrep --color=auto'
  command -v colordiff &>/dev/null && alias diff='colordiff -y -W$(( $(tput cols) - 2 ))'
else
  alias grep='grep --color=auto'
  alias egrep='egrep --color=auto'
  alias diff='diff -y --color -W $(( $(tput cols) - 2 ))'
fi

# docker

alias dk='docker'
alias dkps="docker ps --format '{{.ID}} ~ {{.Names}} ~ {{.Status}} ~ {{.Image}}'"

if command -v docker-compose &> /dev/null; then
  alias dc='docker-compose'
else
  alias dc='echo "docker-compose is not on the path yet"'
fi

# git

alias add='git add'
alias commit='git commit'
alias pull='git pull'
alias push='git push'

# gpg

GPG_TTY=$(tty)
export GPG_TTY

# java

alias java='${HOME}/.sdkman/candidates/java/current/bin/java'
alias javac='${HOME}/.sdkman/candidates/java/current/bin/javac'
JAVA_HOME=$( java -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.home' | cut -d '=' -f 2 | tr -d '[:space:]' )
export JAVA_HOME

function gw {
  if [ -f ./gradlew ]; then
    ./gradlew "$@"
  else
    echo "No ./gradlew here"
  fi
}

# TODO: gradle opts

# k3s

if command -v k3s &> /dev/null; then
  alias kubectl="k3s kubectl"
  source <(k3s completion bash)
  source <(k3s kubectl completion bash)
fi

# node

NPM_PACKAGES="${HOME}/.npm-packages"
if [ ! -d "${NPM_PACKAGES}" ]; then
  mkdir -p "${NPM_PACKAGES}"
fi

if which npm > /dev/null && ! which npm | grep "${NPM_PACKAGES}"; then
  ORIGINAL_NPM=$(which npm)
  $ORIGINAL_NPM config set prefix "${NPM_PACKAGES}"
fi

if [ ! -f "${NPM_PACKAGES}/bin/yarn" ]; then
  warn "NPM/Yarn are not globally installed; run '${ORIGINAL_NPM} install --location=global npm yarn' to resolve"
else
  alias yarn='${NPM_PACKAGES}/bin/yarn'
  alias yarnpkg='${NPM_PACKAGES}/bin/yarnpkg'
  alias npm='${NPM_PACKAGES}/bin/npm'
  alias npx='${NPM_PACKAGES}/bin/npx'
fi

# SDK manager

export SDKMAN_DIR="${HOME}/.sdkman"
if [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
  source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi

# tmux

alias tm="tmux attach || tmux new -s main"

# vim

export EDITOR="${HOME}/bin/start_vim"
alias v='${HOME}/bin/start_vim'
alias vim='${HOME}/bin/start_vim'
alias nvim='${HOME}/bin/start_vim'

function vw {
  old_path="$(pwd)"
  cd ~/vimwiki || exit 1
  nvim +:VimwikiIndex
  cd "$old_path" || exit 1
}

function vd {
  old_path="$(pwd)"
  cd ~/vimwiki || exit 1
  nvim +:VimwikiMakeDiaryNote
  cd "$old_path" || exit 1
}
