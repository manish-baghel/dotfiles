#!/bin/bash
nvim_url="https://github.com/neovim/neovim/releases/download/v0.12.0/nvim-linux-x86_64.tar.gz"

if ! wget "$nvim_url" -O nvim-linux64.tar.gz; then
	echo "Error downloading nvim build"
	exit 1
fi

# Extract the tar.gz
tar xzvf nvim-linux64.tar.gz

# Clean up
rm -f nvim-linux64.tar.gz
