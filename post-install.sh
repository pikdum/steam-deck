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
    # The falloutnv-pre-deploy.desktop was missed in the original script, adding it for consistency if present
    ln -sf ~/.pikdum/steam-deck-master/vortex/falloutnv-pre-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/fallout3-post-deploy.desktop ~/Desktop/
    ln -sf ~/.pikdum/steam-deck-master/vortex/oblivion-post-deploy.desktop ~/Desktop/
    # The main Vortex shortcut is now handled by install-vortex.sh, so no vortex-linux setupVortexDesktop needed
fi

# Ensure Vortex downloads directory exists on SD card, if SD card is mounted and accessible
# This was in the original script, and it's a reasonable thing to keep.
# It's not strictly related to Vortex installation itself but general user convenience.
MOUNTPOINT="$(findmnt /dev/mmcblk0p1 -o TARGET -n || true)" # Added || true to prevent script exit if not found
if [ -n "$MOUNTPOINT" ] && [ -d "$MOUNTPOINT" ]; then
    mkdir -p "$MOUNTPOINT/vortex-downloads" || true
fi
