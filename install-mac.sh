#!/bin/bash

# Update xcode
xcode-select --install 2> /dev/null

# Install brew
if ! [ -f "/usr/local/bin/brew" ]; then
  echo "Installing Hombrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if ! [ -f "/bin/zsh" ]; then
  NO_ZSH_INSTALLED=true
fi

# for gopath
mkdir -p ~/workspace/go

/usr/local/bin/brew install zsh the_silver_searcher tmux neovim git reattach-to-user-namespace tig go

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
cp dotfiles-master/tmux/.tmux.conf ~
cp -a dotfiles-master/nvim ~/.config

# install nvim plugins
/usr/local/bin/nvim +PlugInstall +qa

# install gopls
if ! [ -f "$HOME/workspace/go/bin/gopls" ]; then
  /usr/local/bin/go get golang.org/x/tools/gopls
fi

# volta
if ! [ -f "$HOME/.volta" ]; then
  curl https://get.volta.sh | bash
fi

# install rust
if ! [ -f "$HOME/.cargo" ]; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain=stable --profile=default
fi


