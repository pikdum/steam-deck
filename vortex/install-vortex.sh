#!/usr/bin/env bash
set -euxo pipefail

export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx/"
mkdir -p "$WINEPREFIX"

command -v umu-run >/dev/null || { echo "umu-run not found, please install it."; exit 1; }

VORTEX_VERSION="1.13.7"
PROTON_BUILD="GE-Proton9-23"

PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$PROTON_BUILD/$PROTON_BUILD.tar.gz"
VORTEX_INSTALLER="vortex-setup-$VORTEX_VERSION.exe"
VORTEX_URL="https://github.com/Nexus-Mods/Vortex/releases/download/v$VORTEX_VERSION/$VORTEX_INSTALLER"
DOTNET_URL="https://download.visualstudio.microsoft.com/download/pr/06239090-ba0c-46e2-ad3e-6491b877f481/c5e4ab5e344eb3bdc3630e7b5bc29cd7/windowsdesktop-runtime-6.0.21-win-x64.exe"

# install steam linux runtime sniper
steam steam://install/1628350

# The script is expected to be run from ~/.pikdum/steam-deck-master/vortex/
# as per install-vortex.desktop.in
# So, ensure this directory exists and cd into it.
TARGET_DIR="$HOME/.pikdum/steam-deck-master/vortex"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# Ensure vortex.sh is executable
chmod +x ./vortex.sh

# Download Vortex Installer
wget -O "$VORTEX_INSTALLER" "$VORTEX_URL"

# Download .NET Installer
wget -O "dotnet-installer.exe" "$DOTNET_URL"

# Install .NET Runtime
umu-run "$(pwd)/dotnet-installer.exe" /q /norestart

# Install Vortex
umu-run "$(pwd)/$VORTEX_INSTALLER" /S

# Create dosdevices directory and symlinks
mkdir -p "$WINEPREFIX/dosdevices"
cd "$WINEPREFIX/dosdevices"

if [ -d "$HOME/.steam/steam/steamapps/common/" ]; then
    ln -sfn "$HOME/.steam/steam/steamapps/common/" j: || true
fi

if [ -d "/run/media/mmcblk0p1/steamapps/common/" ]; then
    ln -sfn "/run/media/mmcblk0p1/steamapps/common/" k: || true
fi

# Change back to the script's directory for desktop file operations
cd "$TARGET_DIR"

# Copy the new .desktop file
cp ./vortex.desktop "$HOME/.local/share/applications/vortex.desktop"
update-desktop-database || true

# Update desktop shortcut
rm -f ~/Desktop/install-vortex.desktop
ln -sf ~/.local/share/applications/vortex.desktop ~/Desktop/Vortex.desktop

# Remove old game-specific deploy desktop symlinks (if they existed)
rm -f ~/Desktop/skyrim-post-deploy.desktop
rm -f ~/Desktop/skyrimle-post-deploy.desktop
rm -f ~/Desktop/fallout4-post-deploy.desktop
rm -f ~/Desktop/falloutnv-post-deploy.desktop
rm -f ~/Desktop/falloutnv-pre-deploy.desktop
rm -f ~/Desktop/fallout3-post-deploy.desktop
rm -f ~/Desktop/oblivion-post-deploy.desktop

# Create Vortex downloads directory on SD card if it exists
if [ -d "/run/media/mmcblk0p1/" ]; then
    mkdir -p "/run/media/mmcblk0p1/vortex-downloads" || true
fi

echo "Success! Exiting in 3..."
sleep 3
