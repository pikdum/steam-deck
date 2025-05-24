#!/usr/bin/env bash
set -euxo pipefail

FALLOUTNV_INTERNAL="$HOME/.steam/steam/steamapps/common/Fallout New Vegas/"
FALLOUTNV_EXTERNAL="/run/media/mmcblk0p1/steamapps/common/Fallout New Vegas/"

INIFILES_VORTEX="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/"
INIFILES_INTERNAL="$HOME/.local/share/Steam/steamapps/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/"
INIFILES_EXTERNAL="/run/media/mmcblk0p1/steamapps/compatdata/22380/pfx/drive_c/users/steamuser/Documents/My Games/FalloutNV/"

if [ -d "$INIFILES_EXTERNAL" ]; then
    ln -sf "$INIFILES_EXTERNAL"/Fallout.ini "$INIFILES_VORTEX"/
    ln -sf "$INIFILES_EXTERNAL"/FalloutPrefs.ini "$INIFILES_VORTEX"/
fi

if [ -d "$INIFILES_INTERNAL" ]; then
    ln -sf "$INIFILES_INTERNAL"/Fallout.ini "$INIFILES_VORTEX"/
    ln -sf "$INIFILES_INTERNAL"/FalloutPrefs.ini "$INIFILES_VORTEX"/
fi

sleep 3
