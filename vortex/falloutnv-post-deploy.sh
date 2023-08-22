#!/usr/bin/env bash
set -euxo pipefail

FALLOUTNV_INTERNAL="$HOME/.steam/steam/steamapps/common/Fallout New Vegas/"
FALLOUTNV_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Fallout New Vegas/"

nvse_setup() {
    if [ -d "$1" ] &&
        [ -f "${1}nvse_loader.exe" ] &&
        [ -f "${1}FalloutNVLauncher.exe" ]; then
        cd "$1"
        if ! cmp --silent -- "nvse_loader.exe" "FalloutNVLauncher.exe"; then
            echo "Swapping FalloutNVLauncher.exe for nvse_loader.exe"
            mv FalloutNVLauncher.exe _FalloutNVLauncher.exe
            cp nvse_loader.exe FalloutNVLauncher.exe
        fi
    fi
}

nvse_setup "$FALLOUTNV_INTERNAL"
nvse_setup "$FALLOUTNV_EXTERNAL"

APPDATA_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/falloutnv/"
APPDATA_INTERNAL="$HOME/.local/share/Steam/steamapps/compatdata/22380/pfx/drive_c/users/steamuser/AppData/Local/falloutnv/"
APPDATA_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/22380/pfx/drive_c/users/steamuser/AppData/Local/falloutnv/"

echo "Copying loadorder.txt and plugins.txt"
mkdir -p "$APPDATA_INTERNAL" || true
mkdir -p "$APPDATA_EXTERNAL" || true
cp "$APPDATA_VORTEX"/* "$APPDATA_INTERNAL" || true
cp "$APPDATA_VORTEX"/* "$APPDATA_EXTERNAL" || true

echo "Success! Exiting in 3..."
sleep 3
