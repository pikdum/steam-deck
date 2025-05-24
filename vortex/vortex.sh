#!/usr/bin/env bash
export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx/"
UMU_RUN_WRAPPER="$HOME/.local/bin/umu-run"

# Create the WINEPREFIX directory if it doesn't exist (it should by this point)
mkdir -p "$WINEPREFIX"

VORTEX_INSTALL_DIR="$WINEPREFIX/drive_c/Program Files/Black Tree Gaming Ltd/Vortex"

# Check if Vortex is installed and change to its directory
if [ -d "$VORTEX_INSTALL_DIR" ]; then
  cd "$VORTEX_INSTALL_DIR" || exit 1
else
  # If Vortex isn't installed, attempting to run it will likely fail.
  # We could exit here, or let the umu-run call fail.
  # For now, let it proceed to umu-run, which will show an error.
  echo "Warning: Vortex installation directory not found at $VORTEX_INSTALL_DIR"
  echo "Proceeding to call umu-run, but it may fail if Vortex is not installed."
fi

# NXM link handling (copied from original user example, adapted for wrapper)
if [[ ("$1" == "-d" || "$1" == "-i") && "$2" != *"nxm"* ]]; then
  echo "No url provided for $1, launching Vortex normally."
  exec "$UMU_RUN_WRAPPER" Vortex.exe
else
  exec "$UMU_RUN_WRAPPER" Vortex.exe "$@"
fi
