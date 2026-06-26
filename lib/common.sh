#!/bin/bash
# Shared install steps used by both install-mac.sh and install-linux.sh.
#
# This file is sourced (not executed) by the OS entrypoints after they have
# bootstrapped their package manager and language toolchains (brew / apt +
# curl installers). It relies on `set -euo pipefail` and the version variables
# from versions.env being in scope, and assumes bash.
#
# The split is deliberate: anything that differs by OS (how a binary is
# acquired) lives in the entrypoint; anything identical across OS (which
# version to pin, where to put it) lives here so there is one source of truth.

# darwin | linux — matches Go's release naming.
go_os() {
  case "$(uname -s)" in
    Darwin) echo darwin ;;
    Linux) echo linux ;;
    *) echo "Unsupported OS: $(uname -s)" >&2; return 1 ;;
  esac
}

# amd64 | arm64 — matches Go's release naming.
go_arch() {
  case "$(uname -m)" in
    arm64 | aarch64) echo arm64 ;;
    x86_64 | amd64) echo amd64 ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; return 1 ;;
  esac
}

# Copy tracked config files into $HOME. $1 is the extracted dotfiles repo.
# Copies are written with `dir/.` into an existing target so re-running the
# installer overwrites in place instead of nesting (e.g. ~/.config/nvim/nvim).
install_config() {
  local src="$1"
  mkdir -p "$HOME/.config"
  cp "$src/zsh/.zshrc" "$HOME/.zshrc"
  cp "$src/dircolors/bliss.dircolors" "$HOME/.dircolors"
  cp "$src/tmux/.tmux.conf" "$HOME/"
  mkdir -p "$HOME/.config/nvim" && cp -a "$src/nvim/." "$HOME/.config/nvim/"
  mkdir -p "$HOME/.config/git" && cp -a "$src/git/." "$HOME/.config/git/"
  mkdir -p "$HOME/.gnupg" && cp -a "$src/gnupg/." "$HOME/.gnupg/"
  chmod 700 "$HOME/.gnupg"
}

# Install TPM (the manager) and then the plugins declared in .tmux.conf.
# bin/install_plugins is the non-interactive equivalent of `prefix + I`; without
# it a fresh machine has no tmux plugins until you trigger them by hand.
# Requires .tmux.conf to already be in place (run after install_config).
install_tpm() {
  if ! [ -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  fi
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
}

# Install the pinned Go toolchain from the official tarball. This is the
# recommended way to install a *specific* Go version and behaves identically on
# macOS and Linux (only the os/arch in the URL changes), so it stays consistent
# across both. Re-running is a no-op once the pinned version is present.
install_go() {
  local goroot="$HOME/workspace/go/root"
  mkdir -p "$HOME/workspace/go"

  if [ -x "$goroot/go/bin/go" ] && "$goroot/go/bin/go" version | grep -q "go${GO_VERSION} "; then
    return 0
  fi

  local os arch
  os="$(go_os)"
  arch="$(go_arch)"
  curl -fsSLo /tmp/go.tar.gz "https://go.dev/dl/go${GO_VERSION}.${os}-${arch}.tar.gz"
  rm -rf "$goroot"
  mkdir -p "$goroot"
  tar -C "$goroot" -xzf /tmp/go.tar.gz
}

install_gopls() {
  local goroot="$HOME/workspace/go/root"
  export GOPATH="$HOME/workspace/go"
  export GOBIN="$GOPATH/bin"
  export PATH="$goroot/go/bin:$GOBIN:$PATH"
  if ! [ -x "$GOBIN/gopls" ]; then
    "$goroot/go/bin/go" install golang.org/x/tools/gopls@latest
  fi
}

# Pin Node via fnm. Assumes the `fnm` binary is already on PATH (brew on macOS,
# curl installer into ~/.local/share/fnm on Linux).
install_node() {
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "$(fnm env --shell bash)"
  fnm install "$NODE_VERSION"
  fnm default "$NODE_VERSION"
  fnm use "$NODE_VERSION"
}

# Install the Claude Code and Codex CLIs via their official native installers
# (standalone binaries — no npm/Node dependency). Both land in ~/.local/bin,
# which is already on PATH. Claude Code self-updates in the background and
# re-running either installer just updates in place, so the guards only skip
# redundant downloads on re-runs.
install_agents() {
  export PATH="$HOME/.local/bin:$PATH"
  if ! command -v claude >/dev/null 2>&1; then
    curl -fsSL https://claude.ai/install.sh | bash
  fi
  if ! command -v codex >/dev/null 2>&1; then
    curl -fsSL https://chatgpt.com/codex/install.sh | sh
  fi
}

# Install the pinned 1Password CLI (`op`) from the official standalone zip.
# Same artifact layout on macOS and Linux — only the os/arch in the URL differs,
# and both match go_os/go_arch's naming — so it lives here as one source of
# truth. Lands in ~/.local/bin (already on PATH); 1Password ships signed,
# notarized binaries so the macOS one runs without a Gatekeeper prompt. The
# guard skips the re-download once the pinned version is already installed.
install_op() {
  export PATH="$HOME/.local/bin:$PATH"
  if command -v op >/dev/null 2>&1 && [ "$(op --version 2>/dev/null)" = "$OP_VERSION" ]; then
    return 0
  fi

  local os arch
  os="$(go_os)"
  arch="$(go_arch)"
  curl -fsSLo /tmp/op.zip "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_${os}_${arch}_v${OP_VERSION}.zip"
  rm -rf /tmp/op-extract
  unzip -qo /tmp/op.zip -d /tmp/op-extract
  mkdir -p "$HOME/.local/bin"
  install -m 0755 /tmp/op-extract/op "$HOME/.local/bin/op"
}

# Pin Python via uv. Assumes `uv` is already on PATH.
install_python() {
  export PATH="$HOME/.local/bin:$PATH"
  uv python install "$PYTHON_VERSION"
}

# Pin the Rust toolchain via rustup. Assumes `rustup` is already installed.
install_rust() {
  export PATH="$HOME/.cargo/bin:$PATH"
  rustup toolchain install "$RUST_VERSION"
  rustup default "$RUST_VERSION"
}

# Bootstrap vim-plug explicitly so the install is deterministic instead of
# relying on init.vim's first-launch autocmd, then install plugins headlessly
# and synchronously (no TTY needed under `curl | bash`). Treesitter parsers
# compile via the `do` hook during PlugInstall.
install_nvim_plugins() {
  local plug="$HOME/.config/nvim/autoload/plug.vim"
  if ! [ -f "$plug" ]; then
    curl -fsSLo "$plug" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi
  nvim --headless "+PlugInstall --sync" +qa

  # Install Mason-managed language servers / linters. mason-tool-installer's
  # run_on_start kicks the install on launch (async jobs); we hold the headless
  # session open until it signals completion, with a timeout so a stuck
  # download can't hang the installer forever.
  nvim --headless \
    -c 'autocmd User MasonToolsUpdateCompleted quitall' \
    -c 'lua vim.defer_fn(function() vim.cmd("quitall!") end, 300000)'
}
