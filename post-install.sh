#!/usr/bin/env sh

set -euxo pipefail

ln -sf ~/.pikdum/steam-deck-master/update.desktop ~/Desktop/pikdum-update.desktop

if [ ! -f "$HOME/.local/share/applications/vortex.desktop" ]; then
    ln -s ~/.pikdum/steam-deck-master/vortex/install-vortex.desktop ~/Desktop/install-vortex.desktop || true
fi

mkdir -p /run/media/mmcblk0p1/vortex-downloads || true
