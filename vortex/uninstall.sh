#!/usr/bin/env bash
set -euxo pipefail

DESKTOP_LINK_FILES=(
    "skyrim-post-deploy.desktop" 
    "skyrimle-post-deploy.desktop" 
    "fallout4-post-deploy.desktop" 
    "falloutnv-post-deploy.desktop" 
    "fallout3-post-deploy.desktop" 
    "oblivion-post-deploy.desktop"
    )

# undo game symlinks
bash "$HOME/.pikdum/steam-deck-master/vortex/multi-game-scripts/new-game-setup.desktop uninstall"

# remove these tools
rm -rf "$HOME/.pikdum/"

# remove vortex
rm -rf "$HOME/.vortex-linux/"
rm -rf "$HOME/.local/share/applications/vortex.*"

# remove desktop icons
for desktop_link_file in "${DESKTOP_LINK_FILES[@]}"; do
    rm -rf "$HOME/Desktop/$desktop_link_file"
done

