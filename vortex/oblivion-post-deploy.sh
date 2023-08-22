#!/usr/bin/env bash
set -euxo pipefail

OBLIVION_INTERNAL="$HOME/.steam/steam/steamapps/common/Oblivion/"
OBLIVION_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Oblivion/"

obse_setup() {
    if [ -d "$1" ] &&
        [ -f "${1}obse_loader.exe" ] &&
        [ -f "${1}OblivionLauncher.exe" ]; then
        cd "$1"
        if ! cmp --silent -- "obse_loader.exe" "OblivionLauncher.exe"; then
            echo "Swapping OblivionLauncher.exe for obse_loader.exe"
            mv OblivionLauncher.exe _OblivionLauncher.exe
            cp obse_loader.exe OblivionLauncher.exe
        fi
    fi
}

obse_setup "$OBLIVION_INTERNAL"
obse_setup "$OBLIVION_EXTERNAL"

APPDATA_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Oblivion/"
APPDATA_INTERNAL="$HOME/.local/share/Steam/steamapps/compatdata/22330/pfx/drive_c/users/steamuser/AppData/Local/Oblivion/"
APPDATA_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/22330/pfx/drive_c/users/steamuser/AppData/Local/Oblivion/"

echo "Copying loadorder.txt and plugins.txt"
mkdir -p "$APPDATA_INTERNAL" || true
mkdir -p "$APPDATA_EXTERNAL" || true
cp "$APPDATA_VORTEX"/* "$APPDATA_INTERNAL" || true
cp "$APPDATA_VORTEX"/* "$APPDATA_EXTERNAL" || true

echo "Success! Exiting in 3..."
sleep 3
