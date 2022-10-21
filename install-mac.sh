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

/opt/homebrew/bin/brew install zsh the_silver_searcher tmux neovim git reattach-to-user-namespace tig go

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

# volta
if ! [ -d "$HOME/.volta" ]; then
  curl https://get.volta.sh | bash
fi

# node
if hash node 2> /dev/null; then
  $HOME/.volta/bin/volta install node
fi

# install rust
if ! [ -d "$HOME/.cargo" ]; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain=stable --profile=default
fi

# install nvim plugins
/usr/local/bin/nvim +PlugInstall +qa

echo "Run: Connecting tailscale. `tailscale up`"
echo "Run: Set ZSH default shell. `chsh -s $(which zsh)`"
