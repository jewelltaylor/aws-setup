#!/usr/bin/env bash

# -e: If any command exits with non-zero status, immediately exit script 
# -o pipefail: Exit status of pipe is first non-zero exit code else last command
# Aside: set is bash command that can modify shell options (flags that influence how shell operated)
set -eo pipefail

# Add Node Source repository for Node.js to system and prepare to install with EPEL
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -

# Enable and install EPEL (Extra packages Amazon Linux)
set amazon-linux-extras install -y epel

# Install packages with YUM 
sudo yum groupinstall -y "Development Tools"           # gcc, make, etc.
sudo yum install -y \
  git \
  neovim \
  python3 python3-pip \
  nodejs npm \
  tmux \

# Install ripgrep with Rust
curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
cargo install ripgrep

# Install Lazy.nvim (nvim plugin manager)
LAZYPATH="$HOME/.local/share/nvim/site/pack/lazy/start/lazy.nvim"
if [ ! -d "$LAZYPATH" ]; then
  git clone --filter=blob:none \
    https://github.com/folke/lazy.nvim.git \
    --branch=stable \
    "$LAZYPATH"
fi

# Clone config and move it to appropriate dir
git clone git@github.com:jewelltaylor/nvim-config.git
mv nvim-config/init.lua ~/.config/nvim/init.lua
rm -rf nvim-config

# Headless install of all plugins
nvim --headless +Lazy! +qall

echo "✅ Neovim, tmux, and your config are installed. Next time you launch Neovim, Lazy.nvim will have pulled in all of your plugins (including Telescope)."

