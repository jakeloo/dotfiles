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

# unpacking
cd /tmp
mkdir -p ~/.config
unzip -o dotfiles.zip
cp dotfiles-master/zsh/.zshrc ~/.zshrc
cp dotfiles-master/dircolors/bliss.dircolors ~/.dircolors
cp dotfiles-master/tmux/.tmux.conf ~
cp -a dotfiles-master/nvim ~/.config

# install tpm
if ! [ -f "$HOME/.tmux/plugins/tpm" ]; then
  git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# install go and gopls
GO_VERSION="1.14.2"
curl -sLo /tmp/go.tar.gz https://dl.google.com/go/go$GO_VERSION.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf /tmp/go.tar.gz
if ! [ -f "/usr/local/go/bin/gopls" ]; then
  /usr/local/go/bin/go get golang.org/x/tools/gopls
fi

# volta
if ! [ -f "$HOME/.volta" ]; then
  curl https://get.volta.sh | bash
fi

# node
if hash node 2> /dev/null; then
  $HOME/.volta/bin/volta install node
fi

# install rust
if ! [ -d ~/.cargo ]; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain=stable --profile=default
fi

sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor --skip-auto

# install nvim plugins
nvim +PlugInstall +qa
