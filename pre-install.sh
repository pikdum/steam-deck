#!/usr/bin/env bash

set -euxo pipefail

export WINEPREFIX=@winePrefix@

mkdir -p "$WINEPREFIX"

# These will be replaced by Nix during build
cp @vortexInstaller@ "$WINEPREFIX/vortex-setup.exe"
cp @dotnetInstaller@ "$WINEPREFIX/dotnet-runtime.exe"

# Install .NET runtime silently
@umuLauncher@/bin/umu-run "$WINEPREFIX/dotnet-runtime.exe" /q

# Install Vortex silently
@umuLauncher@/bin/umu-run "$WINEPREFIX/vortex-setup.exe" /S

# Clean up installers
rm -f "$WINEPREFIX/vortex-setup.exe" "$WINEPREFIX/dotnet-runtime.exe"

# Set up drive letter mappings
if [ -d "$HOME/.steam/steam/steamapps/common/" ]; then
  mkdir -p "$WINEPREFIX/dosdevices"
  ln -sfn "$HOME/.steam/steam/steamapps/common/" "$WINEPREFIX/dosdevices/j:" || true
fi

