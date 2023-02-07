#!/usr/bin/env bash
set -euo pipefail

mkdir -p ~/.pikdum
cd ~/.pikdum
wget -O steam-deck.zip https://github.com/pikdum/steam-deck/archive/refs/heads/master.zip
unzip -o steam-deck.zip
rm steam-deck.zip

ln -s ~/.pikdum/steam-deck-master/update.desktop ~/Desktop/pikdum-update.desktop
