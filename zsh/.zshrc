if [[ "$(uname -r)" =~ Microsoft$ ]]; then
  umask 0022
fi

if [[ ! -d ${HOME}/.zinit ]]; then
  mkdir -p ${HOME}/.zinit
  git clone --depth=1 https://github.com/zdharma/zinit.git ${HOME}/.zinit/bin
fi

source $HOME/.zinit/bin/zinit.zsh

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

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

zinit light chrissicool/zsh-256color
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zinit light sindresorhus/pure
zinit ice pick"async.zsh" src"pure.zsh"
zinit ice wait"0" silent pick"history.zsh" lucid
zinit snippet OMZ::lib/history.zsh

autoload -zU promptinit; promptinit
autoload -zU compinit; compinit
zinit cdreplay -q

setopt HIST_IGNORE_SPACE
bindkey -e

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
alias initkc='eval `keychain --eval id_rsa`'

export EDITOR='nvim'
export VOLTA_HOME=$HOME/.volta
export GOROOT=$HOME/workspace/go/root/go
export GOPATH=$HOME/workspace/go
export GOBIN=$GOPATH/bin
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:$GOROOT/bin:$GOBIN:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$VOLTA_HOME/bin:$PATH


