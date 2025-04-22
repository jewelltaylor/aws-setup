#!/usr/bin/env bash

# -e: If any command exits with non-zero status, immediately exit script 
# -o pipefail: Exit status of pipe is first non-zero exit code else last command
# Aside: set is bash command that can modify shell options (flags that influence how shell operated)
set -eo pipefail

# Add Node Source repository for Node.js to system and prepare to install with EPEL
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -

# Enable and install EPEL (Extra packages Amazon Linux)
sudo amazon-linux-extras install -y epel
sudo yum install -y nodejs

# Install packages with YUM 
sudo yum groupinstall -y "Development Tools"           # gcc, make, etc.
sudo yum install -y \
  git \
  python3 python3-pip \
  nodejs \
  tmux

# get the official self‑contained build (needs only glibc ≥ 2.17, so it works on AL2)
NVIM_VER="v0.10.0"   # ← if a newer tag later appears, bump this
curl -fLO "https://github.com/neovim/neovim-releases/releases/download/${NVIM_VER}/nvim-linux64.tar.gz"
sudo rm -rf /opt/nvim                  # clean out an old install if present
sudo tar -C /opt -xzf nvim-linux64.tar.gz
sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
rm nvim-linux64.tar.gz

# Install ripgrep with Rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
cargo install ripgrep

#  Clone Lazy.nvim exactly where your init.lua looks for it
#  stdpath('data') on AL2 is $HOME/.local/share/nvim unless you export XDG_DATA_HOME
LAZYPATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [ ! -d "$LAZYPATH" ]; then
  git clone --filter=blob:none --branch=stable \
    https://github.com/folke/lazy.nvim.git "$LAZYPATH"
fi

# Clone config and move it to appropriate dir
git clone --branch without-copilot --single-branch https://github.com/jewelltaylor/nvim-config 
mkdir -p ~/.config/nvim
mv nvim-config/init.lua ~/.config/nvim/init.lua
rm -rf nvim-config

# Headless install of all plugins
nvim --headless \
  -c 'lua require("lazy")' \
  -c 'lua require("lazy").sync({wait=true})' \
  -c 'qa'

