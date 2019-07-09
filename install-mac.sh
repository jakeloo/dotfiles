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

/usr/local/bin/brew install zsh the_silver_searcher tmux neovim nvm git reattach-to-user-namespace

if ! $NO_ZSH_INSTALLED; then
  echo "Setting ZSH as default shell"
  chsh -s /bin/zsh
fi

if ! [ -d ~/.zplug ]; then
  echo "Installing zplug"
  /bin/zsh zsh/install-zplug.sh
fi

# install .zshrc, nvim, tmux config
curl -sLo /tmp/dotfiles.zip https://github.com/jakeloo/dotfiles/archive/master.zip

cd /tmp
mkdir -p ~/.config
unzip -o dotfiles.zip
cp dotfiles-master/zsh/.zshrc ~/.zshrc
cp dotfiles-master/tmux/.tmux.conf ~
cp -a dotfiles-master/nvim ~/.config

[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh" # loads nvm

# install node
nvm install node --latest-npm
nvm use node

# install nvim plugins
/usr/local/bin/nvim +PlugInstall +qa

