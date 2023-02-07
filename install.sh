#!/usr/bin/env bash
set -euo pipefail

mkdir -p ~/.pikdum
cd ~/.pikdum
wget -O steam-deck.zip https://github.com/pikdum/steam-deck/archive/refs/heads/master.zip
unzip -o steam-deck.zip
rm steam-deck.zip

ln -s ~/.pikdum/steam-deck-master/update.desktop ~/Desktop/pikdum-update.desktop

if [ ! -f "$HOME/.local/share/applications/pikdum-vortex.desktop" ]; then
    ln -s ~/.pikdum/steam-deck-master/vortex/install-vortex.desktop ~/Desktop/install-vortex.desktop
fi
