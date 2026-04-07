#!/bin/bash

set -euo pipefail

if command -v brew >/dev/null 2>&1; then
  HOMEBREW_BIN="$(command -v brew)"
else
  HOMEBREW_BIN="/opt/homebrew/bin/brew"
fi
NO_ZSH_INSTALLED=false
NEOVIM_VERSION="0.12.1"
NODE_VERSION="24.14.1"
PYTHON_VERSION="3.14.3"
RUST_VERSION="1.94.1"
GO_VERSION="1.26.1"

# Update xcode
xcode-select --install 2> /dev/null || true

# Install brew
if ! [ -f "$HOMEBREW_BIN" ]; then
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

export PATH="$(dirname "$HOMEBREW_BIN"):$PATH"

if ! [ -f "/bin/zsh" ]; then
  NO_ZSH_INSTALLED=true
fi

"$HOMEBREW_BIN" install \
  zsh \
  the_silver_searcher \
  tmux \
  git \
  reattach-to-user-namespace \
  tig \
  ripgrep \
  gh \
  jq \
  htop \
  tree \
  wget \
  fnm

if ! $NO_ZSH_INSTALLED; then
  echo "Setting ZSH as default shell"
  chsh -s /bin/zsh
fi

# nvim
cd /tmp
case "$(uname -m)" in
  arm64) NVIM_ARCH="arm64" ;;
  x86_64) NVIM_ARCH="x86_64" ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac
curl -fsSLo /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-macos-${NVIM_ARCH}.tar.gz"
mkdir -p "$HOME/app"
rm -rf "$HOME/app/nvim-macos-${NVIM_ARCH}"
tar -C "$HOME/app" -xzf /tmp/nvim.tar.gz
sudo ln -sfn "$HOME/app/nvim-macos-${NVIM_ARCH}/bin/nvim" /usr/local/bin/nvim

# install .zshrc, nvim, tmux config
curl -sLo /tmp/dotfiles.zip https://github.com/jakeloo/dotfiles/archive/master.zip

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

case "$(uname -m)" in
  arm64) GO_ARCH="arm64" ;;
  x86_64) GO_ARCH="amd64" ;;
esac

if ! [ -x "$GOROOT/go/bin/go" ] || ! "$GOROOT/go/bin/go" version | grep -q "go${GO_VERSION}"; then
  curl -fsSLo /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.darwin-${GO_ARCH}.tar.gz"
  rm -rf "$GOROOT"
  mkdir -p "$GOROOT"
  tar -C "$GOROOT" -xzf /tmp/go.tar.gz
fi

export PATH="$GOROOT/go/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

if ! [ -f "$GOBIN/gopls" ]; then
  "$GOROOT/go/bin/go" install golang.org/x/tools/gopls@latest
fi

# node
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

# install nvim plugins
/usr/local/bin/nvim +PlugInstall +qa

echo "Run: Set ZSH default shell. \`chsh -s $(which zsh)\`"
