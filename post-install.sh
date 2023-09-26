#!/usr/bin/env bash
set -euxo pipefail

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
    ln -sf ~/.pikdum/steam-deck-master/vortex/falloutnv-pre-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/fallout3-post-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/oblivion-post-deploy.desktop ~/Desktop/

    VORTEX_LINUX="v1.3.4"
    PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton8-16/GE-Proton8-16.tar.gz"
    PROTON_BUILD="GE-Proton8-16"

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

mkdir -p /run/media/mmcblk0p1/vortex-downloads || true
