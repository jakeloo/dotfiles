### Added by Zplugin's installer
if [[ ! -d ${HOME}/.zplugin ]]; then
  mkdir -p ${HOME}/.zplugin
  git clone https://github.com/zdharma/zplugin.git ${HOME}/.zplugin/bin
fi

source "$HOME/.zplugin/bin/zplugin.zsh"
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
### End of Zplugin's installer chunk

# Set up the prompt
[[ "$TERM" == "xterm" ]] && export TERM=xterm-256color

if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

PURE_PROMPT_SYMBOL=">"
PURE_PROMPT_VICMD_SYMBOL="<"

zplugin light chrissicool/zsh-256color
zplugin light zsh-users/zsh-autosuggestions
zplugin light zsh-users/zsh-history-substring-search
zplugin ice pick"async.zsh" src"pure.zsh"
zplugin light sindresorhus/pure
zplugin ice wait"0" silent pick"history.zsh" lucid
zplugin snippet OMZ::lib/history.zsh

autoload -zU promptinit; promptinit
autoload -zU compinit; compinit
zplugin cdreplay -q

bindkey -e

# node version manager and os specific commands
export NVM_DIR="$HOME/.nvm"
if [[ "$(uname 2> /dev/null)" = "Darwin" ]]; then
  export NVM_DIR="/usr/local/opt/nvm"
fi
nvm() {
  unfunction "$0"
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
  $0 "$@"
}

if hash keychain 2> /dev/null; then
  eval `keychain --eval id_rsa 2> /dev/null`
fi

function ssh-reagent() {
  for agent in /tmp/ssh-*/agent.*; do
    export SSH_AUTH_SOCK=$agent
    if ssh-add -l 2>&1 > /dev/null; then
      echo Found working SSH Agent:
      ssh-add -l
      return
    fi
  done
  echo Cannot find ssh agent - maybe you should reconnect and forward it?
}

export EDITOR='nvim'

export GOPATH="$HOME/workspace/go"
export GOBIN="$GOPATH/bin"
if [[ ! -d ${GOBIN} ]]; then
  mkdir -p ${GOBIN}
fi

export PATH=$PATH:$GOBIN:/usr/local/go/bin
export PATH=$PATH:$HOME/.cargo/bin

# export PATH=~/anaconda3/bin:/Library/TeX/texbin:$PATH


