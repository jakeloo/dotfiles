#!/bin/bash

set -a

if ! [ -f "/bin/zsh" ]; then
  NO_ZSH_INSTALLED=true
fi

sudo apt-get -y install build-essential libssl-dev software-properties-common 
sudo apt-get -y install python-dev python-pip python3-dev python3-pip
sudo apt-get -y install zsh silversearcher-ag tmux git tig unzip
sudo apt-get -y upgrade

if ! $NO_ZSH_INSTALLED; then
  echo "Setting ZSH as default shell"
  chsh -s /bin/zsh
fi

# nvim
cd /tmp
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
./nvim.appimage --appimage-extract
mkdir -p $HOME/app/nvim
mv squashfs-root $HOME/app/nvim
sudo ln -s $HOME/app/nvim/squashfs-root/AppRun /usr/bin/nvim

# tailgate
curl -fsSL https://tailscale.com/install.sh | sh

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
cp -a dotfiles-master/git ~/.config
cp -a dotfiles-master/gnupg ~/.gnupg

# install tpm
if ! [ -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone --depth=1 https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
fi

# install go and gopls
GOROOT="$HOME/workspace/go/root"
GOPATH="$HOME/workspace/go"
GOBIN="$GOPATH/bin"
GO_VERSION="1.21.3"

if ! [ -d "$GOROOT" ]; then
  curl -sLo /tmp/go.tar.gz https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz
  mkdir -p $GOROOT
  tar -C $GOROOT -xzf /tmp/go.tar.gz
fi

if ! [ -f "$GOBIN/gopls" ]; then
  $GOROOT/go/bin/go get golang.org/x/tools/gopls
fi

# volta
if ! [ -d "$HOME/.volta" ]; then
  curl https://get.volta.sh | bash
fi

# node
if ! hash node 2> /dev/null; then
  $HOME/.volta/bin/volta install node
fi

# install rust
if ! [ -d "$HOME/.cargo" ]; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain=stable --profile=default
fi

# install foundryup
if ! hash foundryup 2> /dev/null; then
  curl -L https://foundry.paradigm.xyz | bash
  source ~/.zshenv
  foundryup
fi

sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor --skip-auto

# install nvim plugins
nvim +PlugInstall +qa

echo "Run: Connecting tailscale. `tailscale up`"
echo "Run: Set ZSH default shell. `chsh -s $(which zsh)`"
