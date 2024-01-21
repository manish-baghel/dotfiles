#!/bin/bash
nvim_nightly_url="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz"
nvim_nightly_checksum="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz.sha256sum"

# Check if checksum.txt file exists
if [[ -f "checksum.txt" ]]; then
	# Compare the checksums
	wget "$nvim_nightly_checksum" -O checksum.new.txt
	if ! diff checksum.new.txt checksum.txt; then
		echo "Checksum mismatch, redownloading"
		mv checksum.new.txt checksum.txt
	else
		echo "Checksum match, already on the latest version"
		rm -f checksum.new.txt
		exit 1
	fi
else
	echo "Checksum not found, downloading now"
	wget "$nvim_nightly_checksum" -O checksum.txt
fi

# Download the latest nightly build
if ! wget "$nvim_nightly_url" -O nvim-linux64.tar.gz; then
	echo "Error downloading nvim nightly build"
	exit 1
fi

# Extract the tar.gz
tar xzvf nvim-linux64.tar.gz

# Clean up
rm -f nvim-linux64.tar.gz
