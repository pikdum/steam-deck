#!/usr/bin/env bash
set -euxo pipefail

SKYRIM_INTERNAL="$HOME/.steam/steam/steamapps/common/Skyrim/"
SKYRIM_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Skyrim/"

skse_setup() {
    if [ -d "$1" ] &&
        [ -f "${1}skse_loader.exe" ] &&
        [ -f "${1}SkyrimLauncher.exe" ]; then
        cd "$1"
        if ! cmp --silent -- "skse_loader.exe" "SkyrimLauncher.exe"; then
            echo "Swapping SkyrimLauncher.exe for skse_loader.exe"
            mv SkyrimLauncher.exe _SkyrimLauncher.exe
            cp skse_loader.exe SkyrimLauncher.exe
        fi
    fi
}

skse_setup "$SKYRIM_INTERNAL"
skse_setup "$SKYRIM_EXTERNAL"

APPDATA_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Skyrim"
APPDATA_INTERNAL="$HOME/.local/share/Steam/steamapps/compatdata/2028782/pfx/drive_c/users/steamuser/AppData/Local/Skyrim/"
APPDATA_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/2028782/pfx/drive_c/users/steamuser/AppData/Local/Skyrim/"

echo "Copying loadorder.txt and plugins.txt"
mkdir -p "$APPDATA_INTERNAL" || true
mkdir -p "$APPDATA_EXTERNAL" || true
cp "$APPDATA_VORTEX"/* "$APPDATA_INTERNAL" || true
cp "$APPDATA_VORTEX"/* "$APPDATA_EXTERNAL" || true

echo "Success! Exiting in 3..."
sleep 3
