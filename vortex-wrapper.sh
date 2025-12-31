#!/usr/bin/env bash
export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx"

cd "$WINEPREFIX/drive_c/Program Files/Black Tree Gaming Ltd/Vortex" || exit 1

exec @umuLauncher@/bin/umu-run Vortex.exe "$@"
