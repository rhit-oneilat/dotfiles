#!/bin/bash
echo "Installing development tools..."

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Python
sudo dnf install -y python3 python3-pip

# Install Node.js & npm
sudo dnf install -y nodejs npm

echo "Development tools installed!"
