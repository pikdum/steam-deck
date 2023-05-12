#!/usr/bin/env bash
set -euxo pipefail

mkdir -p ~/.local/share/applications/

mkdir -p ~/.pikdum
cd ~/.pikdum
wget -O steam-deck.zip https://github.com/pikdum/steam-deck/archive/refs/heads/master.zip
unzip -o steam-deck.zip
rm steam-deck.zip

~/.pikdum/steam-deck-master/post-install.sh

echo "Success! Exiting in 3..."
sleep 3
