#!/usr/bin/env bash

set -euo pipefail

# Create output directories
mkdir -p "$out/bin"
mkdir -p "$out/share/applications"

# Install post-install script
cp "@postInstall@/bin/post-install" "$out/bin/post-install"

# Install vortex wrapper
cp "@vortexWrapper@/bin/vortex-wrapper" "$out/bin/vortex"
chmod +x "$out/bin/vortex"

cp "@postInstall@/bin/post-install" "$out/share/post-install"

# Process and install desktop entry with correct paths
sed \
  -e "s|Exec=\./vortex-wrapper.sh -d %u|Exec=$out/bin/vortex %u|g" \
  -e "s|Icon=\./vortex\.ico|Icon=vortex|g" \
  "@desktopItem@" > "$out/share/applications/vortex.desktop" \
  "@desktopItemIcon@" > "$out/share/applications/vortex.ico"
