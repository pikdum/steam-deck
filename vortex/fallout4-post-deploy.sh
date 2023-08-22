#!/usr/bin/env bash
set -euxo pipefail

FALLOUT4_INTERNAL="$HOME/.steam/steam/steamapps/common/Fallout 4/"
FALLOUT4_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Fallout 4/"

f4se_setup() {
    if [ -d "$1" ] &&
        [ -f "${1}f4se_loader.exe" ] &&
        [ -f "${1}Fallout4Launcher.exe" ]; then
        cd "$1"
        if ! cmp --silent -- "f4se_loader.exe" "Fallout4Launcher.exe"; then
            echo "Swapping Fallout4Launcher.exe for f4se_loader.exe"
            mv Fallout4Launcher.exe _Fallout4Launcher.exe
            cp f4se_loader.exe Fallout4Launcher.exe
        fi
    fi
}

f4se_setup "$FALLOUT4_INTERNAL"
f4se_setup "$FALLOUT4_EXTERNAL"

APPDATA_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Fallout4"
APPDATA_INTERNAL="$HOME/.local/share/Steam/steamapps/compatdata/377160/pfx/drive_c/users/steamuser/AppData/Local/Fallout4/"
APPDATA_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/377160/pfx/drive_c/users/steamuser/AppData/Local/Fallout4/"

echo "Copying loadorder.txt and plugins.txt"
mkdir -p "$APPDATA_INTERNAL" || true
mkdir -p "$APPDATA_EXTERNAL" || true
cp "$APPDATA_VORTEX"/* "$APPDATA_INTERNAL" || true
cp "$APPDATA_VORTEX"/* "$APPDATA_EXTERNAL" || true

echo "Success! Exiting in 3..."
sleep 3
