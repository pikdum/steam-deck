#!/usr/bin/env bash

set -euo pipefail

mkdir -p "$out/share/applications"

cp "@vortexWrapperScript@" "$out/share/applications/vortex-wrapper.sh"
chmod +x "$out/share/applications/vortex-wrapper.sh"
sed "s|\$out|$out|g" "@desktopItem@" | \
  sed "s|\$home|@homeDir@|g" > temp
mv temp "$out/share/applications/vortex.desktop"
cp "@desktopItemIcon@" "$out/share/applications/vortex.ico"
