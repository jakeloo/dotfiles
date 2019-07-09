#!/bin/bash

# Update xcode
xcode-select --install || true

# Install brew
if [[ $(command -v brew) == "" ]]; then
  echo "Installing Hombrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else

/usr/local/bin/brew install zsh the_silver_searcher tmux neovim nvm git reattach-to-user-namespace

chsh -s /bin/zsh
sh ./zsh/install-zplug.sh

# install .zshrc, nvim, tmux config
curl -sLo /tmp/dotfiles.zip https://github.com/jakeloo/dotfiles/archive/master.zip
cd /tmp
mkdir ~/.config
unzip dotfiles.zip
cp dotfiles-master/zsh/.zshrc ~/.zshrc
cp -a dotfiles-master/nvim ~/.config
cp dotfiles-master/tmux/.tmux.conf ~

source ~/.zshrc

# install node
nvm install node --latest-npm
nvm use node

# install nvim plugins
nvim +PlugInstall +qa!

