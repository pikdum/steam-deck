#!/usr/bin/env bash
VORTEX_LINUX="v1.2.1"
PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton8-3/GE-Proton8-3.tar.gz"
VORTEX_URL="https://github.com/Nexus-Mods/Vortex/releases/download/v1.8.3/vortex-setup-1.8.3.exe"
DOTNET_URL="https://download.visualstudio.microsoft.com/download/pr/85473c45-8d91-48cb-ab41-86ec7abc1000/83cd0c82f0cde9a566bae4245ea5a65b/windowsdesktop-runtime-6.0.16-win-x64.exe"
PROTON_BUILD="GE-Proton8-3"
VORTEX_INSTALLER="vortex-setup-1.8.3.exe"

printf "%s\n" "INFO: Attempting to install Vortex-Linux version: $VORTEX_LINUX";
# install steam linux runtime sniper
steam steam://install/1628350

mkdir -p ~/.pikdum/steam-deck-master/vortex/

cd ~/.pikdum/steam-deck-master/vortex/

rm -rf vortex-linux || true
wget https://github.com/pikdum/vortex-linux/releases/download/$VORTEX_LINUX/vortex-linux
chmod +x vortex-linux

# set STEAM_RUNTIME_PATH to internal storage or sd card
if [ -f "$HOME/.steam/steam/steamapps/common/SteamLinuxRuntime_sniper/run" ]; then
    STEAM_RUNTIME_PATH="$HOME/.steam/steam/steamapps/common/SteamLinuxRuntime_sniper"
elif [ -f "/run/media/mmcblk0p1/steamapps/common/SteamLinuxRuntime_sniper/run" ]; then
    STEAM_RUNTIME_PATH="/run/media/mmcblk0p1/steamapps/common/SteamLinuxRuntime_sniper"
else
    printf "%s\n" "INFO: SteamLinuxRuntime Sniper not found!";
    sleep 3
    exit 1
fi

./vortex-linux setConfig STEAM_RUNTIME_PATH $STEAM_RUNTIME_PATH
./vortex-linux downloadProton "$PROTON_URL"
./vortex-linux setProton "$PROTON_BUILD"
./vortex-linux downloadVortex "$VORTEX_URL"
./vortex-linux protonRunUrl "$DOTNET_URL" /q
./vortex-linux setupVortexDesktop
./vortex-linux installVortex "$VORTEX_INSTALLER"

cd ~/.vortex-linux/compatdata/pfx/dosdevices

if [ -d "$HOME/.steam/steam/steamapps/common/" ]; then
    ln -s "$HOME/.steam/steam/steamapps/common/" j: || true
fi

if [ -d "/run/media/mmcblk0p1/steamapps/common/" ]; then
    ln -s "/run/media/mmcblk0p1/steamapps/common/" k: || true
fi

update-desktop-database || true

rm -f ~/Desktop/install-vortex.desktop
ln -sf ~/.local/share/applications/vortex.desktop ~/Desktop/
ln -sf ~/.pikdum/steam-deck-master/vortex/vortex-tools.desktop ~/Desktop/

mkdir -p /run/media/mmcblk0p1/vortex-downloads || true

printf "%s\n" "SUCCESS: Closing in 3..."
sleep 3
