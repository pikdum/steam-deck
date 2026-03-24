#!/usr/bin/env bash
set -euxo pipefail

VORTEX_VERSION="1.15.2"
VORTEX_INSTALLER="vortex-setup-$VORTEX_VERSION.exe"
VORTEX_URL="https://github.com/Nexus-Mods/Vortex/releases/download/v$VORTEX_VERSION/$VORTEX_INSTALLER"
DOTNET_URL="https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/9.0.13/windowsdesktop-runtime-9.0.13-win-x64.exe"

export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx"

mkdir -p ~/.pikdum/steam-deck-master/vortex/
cd ~/.pikdum/steam-deck-master/vortex/

# Install umu-launcher
./install-umu.sh

# Download Vortex installer
wget -O "$VORTEX_INSTALLER" "$VORTEX_URL"

# Install .NET runtime
wget -O dotnet-runtime.exe "$DOTNET_URL"
~/.pikdum/umu/umu-run dotnet-runtime.exe /q

# Install Vortex
~/.pikdum/umu/umu-run "$VORTEX_INSTALLER" /S

# Create desktop file
mkdir -p ~/.local/share/applications
cp ~/.pikdum/steam-deck-master/vortex/vortex.desktop ~/.local/share/applications/

# Set up drive letter mappings for Steam libraries
cd "$WINEPREFIX/dosdevices"

if [ -d "$HOME/.steam/steam/steamapps/common/" ]; then
    ln -s "$HOME/.steam/steam/steamapps/common/" j: || true
fi

MOUNTPOINT="$(findmnt /dev/mmcblk0p1 -o TARGET -n)"
if [ -d "$MOUNTPOINT/steamapps/common/" ]; then
    ln -s "$MOUNTPOINT/steamapps/common/" k: || true
fi

update-desktop-database || true

rm -f ~/Desktop/install-vortex.desktop
ln -sf ~/.local/share/applications/vortex.desktop ~/Desktop/
ln -sf ~/.pikdum/steam-deck-master/vortex/skyrim-post-deploy.desktop ~/Desktop/
ln -sf ~/.pikdum/steam-deck-master/vortex/skyrimle-post-deploy.desktop ~/Desktop/
ln -sf ~/.pikdum/steam-deck-master/vortex/fallout4-post-deploy.desktop ~/Desktop/
ln -sf ~/.pikdum/steam-deck-master/vortex/falloutnv-post-deploy.desktop ~/Desktop/
ln -sf ~/.pikdum/steam-deck-master/vortex/falloutnv-pre-deploy.desktop ~/Desktop/
ln -sf ~/.pikdum/steam-deck-master/vortex/fallout3-post-deploy.desktop ~/Desktop/
ln -sf ~/.pikdum/steam-deck-master/vortex/oblivion-post-deploy.desktop ~/Desktop/

mkdir -p $MOUNTPOINT/vortex-downloads || true

echo "Success! Exiting in 3..."
sleep 3
