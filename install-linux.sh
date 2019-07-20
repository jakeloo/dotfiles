#!/bin/bash

if ! [ -f "/bin/zsh" ]; then
  NO_ZSH_INSTALLED=true
fi

mkdir -p ~/workspace/go

sudo add-apt-repository -y ppa:neovim-ppa/stable
sudo apt-get -y install build-essential libssl-dev software-properties-common python-software-properties
sudo apt-get -y install python-dev python-pip python3-dev python3-pip
sudo apt-get -y install zsh silversearcher-ag tmux git tig unzip neovim
sudo apt-get -y upgrade

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

NVM_DIR="$HOME/.nvm"
NVM_VERSION="v0.34.0"
mkdir -p $NVM_DIR
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# install node
nvm install node --latest-npm
nvm use node

# install nvim plugins
/usr/local/bin/nvim +PlugInstall +qa

# install go and gopls
GO_VERSION="1.12.7"
curl -sLo /tmp/go.tar.gz https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
if ! [ -f "/usr/local/go/bin/gopls" ]; then
  /usr/local/go/bin/go get golang.org/x/tools/gopls
fi

# install rust
if ! [ -d ~/.cargo ]; then
  curl https://sh.rustup.rs -sSf | sh
fi

sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor --skip-auto

