#!/usr/bin/env bash
set -euxo pipefail

# Clean up old proton builds
rm -rf ~/.vortex-linux/proton-builds/

echo "Templating files..."
pushd ~/.pikdum/steam-deck-master/
find . -type f -name "*.in" -exec sh -c 'envsubst < "$1" > "${1%.in}" && chmod +x "${1%.in}"' _ {} \;
popd

ln -sf ~/.pikdum/steam-deck-master/update.desktop ~/Desktop/pikdum-update.desktop

if [ ! -f "$HOME/.local/share/applications/vortex.desktop" ]; then
    echo "Creating Vortex install desktop shortcut..."
    ln -s ~/.pikdum/steam-deck-master/vortex/install-vortex.desktop ~/Desktop/install-vortex.desktop || true
else
    echo "Creating Vortex desktop shortcuts..."
    ln -sf ~/.local/share/applications/vortex.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/skyrim-post-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/skyrimle-post-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/fallout4-post-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/falloutnv-post-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/fallout3-post-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/oblivion-post-deploy.desktop ~/Desktop/

    echo "Vortex is already installed, updating umu-launcher..."
    ~/.pikdum/steam-deck-master/vortex/install-umu.sh
fi

MOUNTPOINT="$(findmnt /dev/mmcblk0p1 -o TARGET -n)"

mkdir -p $MOUNTPOINT/vortex-downloads || true
