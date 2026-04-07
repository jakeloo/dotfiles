#!/bin/bash

# Update xcode
xcode-select --install 2> /dev/null

# Install brew
if ! [ -f "/opt/homebrew/bin/brew" ]; then
  echo "Installing Hombrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! [ -f "/bin/zsh" ]; then
  NO_ZSH_INSTALLED=true
fi

/opt/homebrew/bin/brew install zsh the_silver_searcher tmux neovim git reattach-to-user-namespace tig go ripgrep gh

if ! $NO_ZSH_INSTALLED; then
  echo "Setting ZSH as default shell"
  chsh -s /bin/zsh
fi

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
  git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# install gopls
if ! [ -f "$HOME/workspace/go/bin/gopls" ]; then
  /usr/local/bin/go get golang.org/x/tools/gopls
fi

# fnm (node version manager)
if ! command -v fnm &> /dev/null; then
  /opt/homebrew/bin/brew install fnm
fi

# node
if ! hash node 2> /dev/null; then
  eval "$(fnm env)"
  fnm install --lts
fi

# claude code
if ! hash claude 2>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
fi

# codex
if ! npm list -g @openai/codex 2>/dev/null | grep -q '@openai/codex'; then
  npm install -g @openai/codex
fi

# pnpm
if ! hash pnpm 2>/dev/null; then
  curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

# uv
if ! hash uv 2>/dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# install rust
if ! [ -d "$HOME/.cargo" ]; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain=stable --profile=default
fi

# install nvim plugins
/usr/local/bin/nvim +PlugInstall +qa

echo "Run: Connecting tailscale. `tailscale up`"
echo "Run: Set ZSH default shell. `chsh -s $(which zsh)`"
