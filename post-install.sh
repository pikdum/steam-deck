#!/usr/bin/env bash
set -euxo pipefail

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
    ln -sf ~/.pikdum/steam-deck-master/vortex/skyrim-post-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/skyrimle-post-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/fallout4-post-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/falloutnv-post-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/fallout3-post-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/oblivion-post-deploy.desktop ~/Desktop/

    VORTEX_LINUX="v1.3.4"
    PROTON_BUILD="GE-Proton8-27"

    PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$PROTON_BUILD/$PROTON_BUILD.tar.gz"

    echo "Updating vortex-linux..."
    pushd ~/.pikdum/steam-deck-master/vortex/
    rm -rf vortex-linux || true
    wget https://github.com/pikdum/vortex-linux/releases/download/$VORTEX_LINUX/vortex-linux
    chmod +x vortex-linux
    popd

    ~/.pikdum/steam-deck-master/vortex/vortex-linux setupVortexDesktop

    if [ ! -d "$HOME/.vortex-linux/proton-builds/$PROTON_BUILD" ]; then
        echo "Removing old Proton builds..."
        rm -rf $HOME/.vortex-linux/proton-builds/*
        echo "Upgrading Proton to $PROTON_BUILD..."
        ~/.pikdum/steam-deck-master/vortex/vortex-linux downloadProton "$PROTON_URL"
        ~/.pikdum/steam-deck-master/vortex/vortex-linux setProton "$PROTON_BUILD"
    fi
fi

MOUNTPOINT="$(findmnt /dev/mmcblk0p1 -o TARGET -n)"

mkdir -p $MOUNTPOINT/vortex-downloads || true
