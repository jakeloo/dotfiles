if [[ "$(uname -r)" =~ Microsoft$ ]]; then
  umask 0022
fi

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d ${ZINIT_HOME} ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

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

ssh-reagent () {
  userid=${1-`id -u`}
  sockets=$(find /tmp -user $userid -ipath '*ssh*agent*' -print 2>/dev/null)

  for sock (${(f)sockets}); do
    export SSH_AUTH_SOCK=$sock
    if ssh-add -l 2>&1 > /dev/null; then
      ssh-add -l
      set +x
      return 0
    fi
  done

  set +x
  return 1
}

if hash keychain 2> /dev/null; then
  eval `keychain --eval id_rsa --noask 2> /dev/null`
fi
alias initkc='eval `keychain --eval id_rsa`'

export GPG_TTY=$(tty)

export EDITOR='nvim'
export VOLTA_HOME=$HOME/.volta
export GOROOT=$HOME/workspace/go/root/go
export GOPATH=$HOME/workspace/go
export GOBIN=$GOPATH/bin
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:$GOROOT/bin:$GOBIN:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$VOLTA_HOME/bin:$PATH

