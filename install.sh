#!/bin/bash
echo "Setting up your environment..."

# Install necessary packages
sudo dnf install -y git neovim tmux alacritty

# Create symlinks
ln -sf ~/dotfiles/.bashrc ~/.bashrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/.config/nvim ~/.config/nvim
ln -sf ~/dotfiles/.config/hypr ~/.config/hypr

echo "Done! Restart your terminal to apply changes."
