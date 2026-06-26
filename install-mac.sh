#!/bin/bash
#
# macOS bootstrap. Wrapped in main() and invoked on the last line so a truncated
# `curl | bash` download never executes a partial script.

set -euo pipefail

main() {
  local HOMEBREW_BIN
  if command -v brew >/dev/null 2>&1; then
    HOMEBREW_BIN="$(command -v brew)"
  else
    HOMEBREW_BIN="/opt/homebrew/bin/brew"
  fi
  local NO_ZSH_INSTALLED=false

  # Update xcode
  xcode-select --install 2>/dev/null || true

  # Install brew
  if ! [ -f "$HOMEBREW_BIN" ]; then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  local HOMEBREW_DIR
  HOMEBREW_DIR="$(dirname "$HOMEBREW_BIN")"
  export PATH="$HOMEBREW_DIR:$PATH"

  if ! [ -f "/bin/zsh" ]; then
    NO_ZSH_INSTALLED=true
  fi

  # Packages, plus the toolchain bootstrappers (fnm/uv/rustup/bun/pnpm) that the
  # shared install steps pin specific versions of.
  "$HOMEBREW_BIN" install \
    zsh \
    neovim \
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
    fnm \
    pnpm \
    uv \
    bun \
    rustup

  if ! $NO_ZSH_INSTALLED; then
    local CURRENT_SHELL
    CURRENT_SHELL="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"
    if [ "$CURRENT_SHELL" != "/bin/zsh" ]; then
      echo "Setting ZSH as default shell"
      chsh -s /bin/zsh
    fi
  fi

  # Bootstrap rustup itself (brew ships rustup-init, not an initialized toolchain).
  if ! [ -d "$HOME/.cargo" ]; then
    rustup-init -y --profile minimal --no-modify-path
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

  install_config "$DOTFILES"
  install_tpm
  install_go
  install_gopls
  install_node
  install_agents
  install_op
  install_python
  install_rust
  install_nvim_plugins

  echo "Run: Set ZSH default shell. \`chsh -s $(which zsh)\`"
}

main "$@"
