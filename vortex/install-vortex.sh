#!/usr/bin/env bash
set -euxo pipefail

mkdir -p ~/.pikdum/install-vortex-tmp
trap 'rm -rf ~/.pikdum/install-vortex-tmp' EXIT

cd ~/.pikdum/install-vortex-tmp

wget -O stl.zip https://github.com/sonic2kk/steamtinkerlaunch/archive/refs/tags/v12.0.zip
unzip -o stl.zip

cd steamtinkerlaunch-12.0
./steamtinkerlaunch

cd ~/stl/prefix/
sed -i 's/VORTEXSETUP=".*/VORTEXSETUP=vortex-setup-1.7.8.exe/' steamtinkerlaunch
./steamtinkerlaunch vortex install

mkdir -p ~/.local/share/applications/
ln -sf ~/.pikdum/steam-deck-master/vortex/pikdum-vortex.desktop ~/.local/share/applications/
update-desktop-database || true

rm -f ~/Desktop/install-vortex.desktop
ln -sf ~/.pikdum/steam-deck-master/vortex/pikdum-vortex.desktop ~/Desktop/
ln -sf ~/.pikdum/steam-deck-master/vortex/skyrim-post-deploy.desktop ~/Desktop/

mkdir -p /run/media/mmcblk0p1/vortex-downloads || true

echo "Success! Exiting in 3..."
sleep 3
