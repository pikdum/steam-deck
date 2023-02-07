#!/usr/bin/env bash
set -euo pipefail

mkdir -p ~/.pikdum/install-vortex-tmp
trap 'rm -rf ~/.pikdum/install-vortex-tmp' EXIT

cd ~/.pikdum/install-vortex-tmp

wget -O stl.zip https://github.com/sonic2kk/steamtinkerlaunch/archive/refs/tags/v12.0.zip
unzip -o stl.zip

cd steamtinkerlaunch-12.0
./steamtinkerlaunch

cd ~/stl/prefix/
./steamtinkerlaunch vortex install

ln -sf ~/.pikdum/steam-deck-master/vortex/pikdum-vortex.desktop ~/.local/share/applications/
update-desktop-database

rm -f ~/Desktop/install-vortex.desktop
