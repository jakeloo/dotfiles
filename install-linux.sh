#!/bin/bash
#
# Linux (Debian/Ubuntu) bootstrap. Wrapped in main() and invoked on the last
# line so a truncated `curl | bash` download never executes a partial script.

set -euo pipefail

main() {
  local NO_ZSH_INSTALLED=false
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
    local CURRENT_SHELL
    CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7)"
    if [ "$CURRENT_SHELL" != "/bin/zsh" ]; then
      echo "Setting ZSH as default shell"
      sudo usermod -s /bin/zsh "$USER"
    fi
  fi

  # Fetch the dotfiles repo: source of truth for versions, shared install
  # functions, and the config files themselves.
  local DOTFILES_REF="${DOTFILES_REF:-master}"
  local DOTFILES="/tmp/dotfiles-${DOTFILES_REF}"
  curl -fsSLo /tmp/dotfiles.zip "https://github.com/jakeloo/dotfiles/archive/${DOTFILES_REF}.zip"
  rm -rf "$DOTFILES"
  unzip -qo /tmp/dotfiles.zip -d /tmp

  # shellcheck source=versions.env
  . "$DOTFILES/versions.env"
  # shellcheck source=lib/common.sh
  . "$DOTFILES/lib/common.sh"

  # nvim (prebuilt release tarball; macOS gets this from Homebrew instead).
  local NVIM_ARCH
  case "$(uname -m)" in
    x86_64) NVIM_ARCH="x86_64" ;;
    aarch64 | arm64) NVIM_ARCH="arm64" ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
  esac
  curl -fsSLo /tmp/nvim.tar.gz "https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz"
  mkdir -p "$HOME/app"
  rm -rf "$HOME/app/nvim-linux-${NVIM_ARCH}"
  tar -C "$HOME/app" -xzf /tmp/nvim.tar.gz
  sudo ln -sfn "$HOME/app/nvim-linux-${NVIM_ARCH}/bin/nvim" /usr/bin/nvim

  # tailscale
  curl -fsSL https://tailscale.com/install.sh | sh

  # Toolchain bootstrappers (the shared install steps pin specific versions of
  # Node/Python/Rust against these).
  if ! command -v fnm >/dev/null 2>&1; then
    curl -fsSL https://fnm.vercel.app/install | bash
  fi
  if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi
  if ! [ -d "$HOME/.cargo" ]; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal
  fi
  if ! command -v bun >/dev/null 2>&1; then
    curl -fsSL https://bun.sh/install | bash
  fi
  if ! command -v pnpm >/dev/null 2>&1; then
    curl -fsSL https://get.pnpm.io/install.sh | sh -
  fi

  install_config "$DOTFILES"
  install_tpm
  install_go
  install_gopls
  install_node
  install_agents
  install_python
  install_rust
  install_nvim_plugins

  sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
  sudo update-alternatives --set editor /usr/bin/nvim

  echo "Run: Connecting tailscale. \`tailscale up\`"
  echo "Run: Set ZSH default shell. \`chsh -s $(which zsh)\`"
}

main "$@"
