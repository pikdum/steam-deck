#!/usr/bin/env bash

set -euo pipefail

# Create output directories
mkdir -p "$out/bin"
mkdir -p "$out/share/applications"


cp "@vortexWrapperScript@" "$out/share/applications/vortex-wrapper.sh"
chmod +x "$out/share/applications/vortex-wrapper.sh"
cp "@desktopItem@" "$out/share/applications/vortex.desktop"
cp "@desktopItemIcon@" "$out/share/applications/vortex.ico"
