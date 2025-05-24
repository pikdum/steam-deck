#!/usr/bin/env bash
export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx/"

# Create the WINEPREFIX directory if it doesn't exist
mkdir -p "$WINEPREFIX"

# It's good practice to ensure the Vortex installation path exists before trying to cd into it.
# However, this script will likely be called by the .desktop file after installation via install-vortex.sh.
# If Vortex is not installed, umu-run will likely fail, which is acceptable.
VORTEX_INSTALL_DIR="$WINEPREFIX/drive_c/Program Files/Black Tree Gaming Ltd/Vortex"

# Check if directory exists, if not, Vortex might not be installed yet.
# In such a case, umu-run will be called without changing directory,
# which might be handled by umu or fail gracefully.
if [ -d "$VORTEX_INSTALL_DIR" ]; then
  cd "$VORTEX_INSTALL_DIR" || exit 1
else
  echo "Warning: Vortex installation directory not found at $VORTEX_INSTALL_DIR"
  echo "Proceeding to run umu-run, but it may fail if Vortex is not installed."
fi

# Check for -d or -i with no "nxm" in the following argument (for NXM link handling)
if [[ ("$1" == "-d" || "$1" == "-i") && "$2" != *"nxm"* ]]; then
  echo "No url provided for $1, launching Vortex normally."
  exec umu-run Vortex.exe
else
  # For NXM links or direct launch, PROTON_VERB might not be needed with umu-run
  # umu-run handles the execution context.
  # export PROTON_VERB="runinprefix" # This was in the user's example, but umu handles this.
  exec umu-run Vortex.exe "$@"
fi
