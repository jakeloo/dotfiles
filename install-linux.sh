#!/bin/bash

set -euo pipefail

NO_ZSH_INSTALLED=false
NEOVIM_VERSION="0.12.1"
NODE_VERSION="24.14.1"
PYTHON_VERSION="3.14.3"
RUST_VERSION="1.94.1"
GO_VERSION="1.26.1"

if ! [ -f "/bin/zsh" ]; then
  NO_ZSH_INSTALLED=true
fi

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install \
  build-essential \
  software-properties-common \
  ca-certificates \
  curl \
  wget \
  unzip \
  git \
  gh \
  tig \
  jq \
  htop \
  tree \
  ripgrep \
  silversearcher-ag \
  tmux \
  zsh \
  libssl-dev

if ! $NO_ZSH_INSTALLED; then
  echo "Setting ZSH as default shell"
  chsh -s /bin/zsh
fi

# nvim
cd /tmp
case "$(uname -m)" in
  x86_64) NVIM_ARCH="x86_64" ;;
  aarch64|arm64) NVIM_ARCH="arm64" ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
curl -fsSLo /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz"
mkdir -p "$HOME/app"
rm -rf "$HOME/app/nvim-linux-${NVIM_ARCH}"
tar -C "$HOME/app" -xzf /tmp/nvim.tar.gz
sudo ln -sfn "$HOME/app/nvim-linux-${NVIM_ARCH}/bin/nvim" /usr/bin/nvim

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# install .zshrc, nvim, tmux config
curl -sLo /tmp/dotfiles.zip https://github.com/jakeloo/dotfiles/archive/master.zip

# unpacking
cd /tmp
mkdir -p ~/.config
unzip -o dotfiles.zip
cp dotfiles-master/zsh/.zshrc ~/.zshrc
cp dotfiles-master/dircolors/bliss.dircolors ~/.dircolors
cp dotfiles-master/tmux/.tmux.conf ~
cp -a dotfiles-master/nvim ~/.config
cp -a dotfiles-master/git ~/.config
cp -a dotfiles-master/gnupg ~/.gnupg

# install tpm
if ! [ -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# install go and gopls
GOROOT="$HOME/workspace/go/root"
GOPATH="$HOME/workspace/go"
GOBIN="$GOPATH/bin"
mkdir -p "$GOPATH"

if ! [ -x "$GOROOT/go/bin/go" ] || ! "$GOROOT/go/bin/go" version | grep -q "go${GO_VERSION}"; then
  curl -fsSLo /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
  rm -rf "$GOROOT"
  mkdir -p "$GOROOT"
  tar -C "$GOROOT" -xzf /tmp/go.tar.gz
fi

export PATH="$GOROOT/go/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

if ! [ -f "$GOBIN/gopls" ]; then
  "$GOROOT/go/bin/go" install golang.org/x/tools/gopls@latest
fi

# fnm (node version manager)
if ! command -v fnm &> /dev/null; then
  curl -fsSL https://fnm.vercel.app/install | bash
fi

export PATH="$HOME/.local/share/fnm:$PATH"
eval "$(fnm env --shell bash)"
fnm install "$NODE_VERSION"
fnm default "$NODE_VERSION"

# claude code
if ! npm list -g @anthropic-ai/claude-code 2>/dev/null | grep -q '@anthropic-ai/claude-code'; then
  npm install -g @anthropic-ai/claude-code
fi

# codex
if ! npm list -g @openai/codex 2>/dev/null | grep -q '@openai/codex'; then
  npm install -g @openai/codex
fi

# pnpm
if ! hash pnpm 2>/dev/null; then
  curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

# uv and python
if ! hash uv 2>/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi
uv python install "$PYTHON_VERSION"

# install rust
if ! [ -d "$HOME/.cargo" ]; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal
  export PATH="$HOME/.cargo/bin:$PATH"
fi
rustup toolchain install "$RUST_VERSION"
rustup default "$RUST_VERSION"

# bun
if ! hash bun 2>/dev/null; then
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
fi

sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --set editor /usr/bin/nvim

# install nvim plugins
nvim +PlugInstall +qa

echo "Run: Connecting tailscale. \`tailscale up\`"
echo "Run: Set ZSH default shell. \`chsh -s $(which zsh)\`"
