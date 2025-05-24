#!/usr/bin/env bash
set -euxo pipefail

FALLOUT3_INTERNAL="$HOME/.steam/steam/steamapps/common/Fallout 3/"
FALLOUT3_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Fallout 3/"

fose_setup() {
    if [ -d "$1" ] &&
        [ -f "${1}fose_loader.exe" ] &&
        [ -f "${1}Fallout3Launcher.exe" ]; then
        cd "$1"
        if ! cmp --silent -- "fose_loader.exe" "Fallout3Launcher.exe"; then
            echo "Swapping Fallout3Launcher.exe for fose_loader.exe"
            mv Fallout3Launcher.exe _Fallout3Launcher.exe
            cp fose_loader.exe Fallout3Launcher.exe
        fi
    fi
}

fose_setup "$FALLOUT3_INTERNAL"
fose_setup "$FALLOUT3_EXTERNAL"

DOCS_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/Documents/My Games/Fallout3"
APPDATA_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Fallout3"
APPDATA_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/22300/pfx/drive_c/users/steamuser/AppData/Local/fallout3/"

echo "Copying loadorder.txt and plugins.txt"
mkdir -p "$APPDATA_INTERNAL" || true
mkdir -p "$APPDATA_EXTERNAL" || true
cp "$APPDATA_VORTEX"/* "$APPDATA_INTERNAL" || true
cp "$APPDATA_VORTEX"/* "$APPDATA_EXTERNAL" || true
# use Plugins.txt instead of plugins.txt
mv "$APPDATA_INTERNAL/plugins.txt" "$APPDATA_INTERNAL/Plugins.txt" || true
mv "$APPDATA_EXTERNAL/plugins.txt" "$APPDATA_EXTERNAL/Plugins.txt" || true

echo "Success! Exiting in 3..."
sleep 3
