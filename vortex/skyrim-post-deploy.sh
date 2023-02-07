#!/usr/bin/env sh
set -euxo pipefail

cd "$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/"

if ! cmp --silent -- "skse64_loader.exe" "SkyrimSELauncher.exe"; then
    echo "Swapping SkyrimSELauncher.exe for skse64_loader.exe"
    cd "$HOME/.steam/steam/steamapps/common/Skyrim Special Edition/"
    mv SkyrimSELauncher.exe _SkyrimSELauncher.exe
    cp skse64_loader.exe SkyrimSELauncher.exe
fi

echo "Copying loadorder.txt and plugins.txt"
cp "$HOME/.config/steamtinkerlaunch/vortex/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition"/* "$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition/"
