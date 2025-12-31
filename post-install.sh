#!/usr/bin/env bash

set -euxo pipefail

export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx"

mkdir -p "$WINEPREFIX"

# These will be replaced by Nix during build
cp @vortexInstaller@ ./vortex-setup.exe
cp @dotnetRuntime@ ./dotnet-runtime.exe

# Install .NET runtime silently
@umuLauncher@/bin/umu-run dotnet-runtime.exe /q

# Install Vortex silently
@umuLauncher@/bin/umu-run vortex-setup.exe /S

# Set up drive letter mappings
if [ -d "$HOME/.steam/steam/steamapps/common/" ]; then
  mkdir -p "$WINEPREFIX/dosdevices"
  ln -sfn "$HOME/.steam/steam/steamapps/common/" "$WINEPREFIX/dosdevices/j:" || true
fi
