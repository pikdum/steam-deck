#!/usr/bin/env bash
set -euxo pipefail

UMU_VERSION="1.2.6"
UMU_URL="https://github.com/Open-Wine-Components/umu-launcher/releases/download/$UMU_VERSION/umu-launcher-$UMU_VERSION-zipapp.tar"
UMU_DIR="$HOME/.pikdum/umu"

echo "Installing umu-launcher $UMU_VERSION..."

# Create umu directory
mkdir -p "$UMU_DIR"
cd "$UMU_DIR"

# Download umu-launcher
echo "Downloading umu-launcher from $UMU_URL..."
wget -O "umu-launcher-$UMU_VERSION-zipapp.tar" "$UMU_URL"

# Extract with strip-components to remove leading directory
echo "Extracting umu-launcher..."
tar --strip-components=1 -xf "umu-launcher-$UMU_VERSION-zipapp.tar"

# Make all files executable
chmod +x *

# Clean up downloaded archive
rm "umu-launcher-$UMU_VERSION-zipapp.tar"

echo "umu-launcher installation completed successfully!"
