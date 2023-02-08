#!/usr/bin/env bash
set -euxo pipefail

mkdir -p ~/.pikdum
cd ~/.pikdum
wget -O steam-deck.zip https://github.com/pikdum/steam-deck/archive/refs/heads/master.zip
unzip -o steam-deck.zip
rm steam-deck.zip

ln -sf ~/.pikdum/steam-deck-master/update.desktop ~/Desktop/pikdum-update.desktop

if [ ! -f "$HOME/.local/share/applications/pikdum-vortex.desktop" ]; then
    ln -s ~/.pikdum/steam-deck-master/vortex/install-vortex.desktop ~/Desktop/install-vortex.desktop
fi

mkdir -p /run/media/mmcblk0p1/vortex-downloads || true

echo "Success! Exiting in 3..."
sleep 3
