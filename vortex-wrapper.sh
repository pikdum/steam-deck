#!/usr/bin/env bash
set -euo pipefail

export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx"

exec @umuLauncher@/bin/umu-run "$WINEPREFIX/drive_c/Program Files/Black Tree Gaming Ltd/Vortex/Vortex.exe" "$@"
