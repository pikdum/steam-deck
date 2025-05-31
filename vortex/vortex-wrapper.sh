#!/usr/bin/env bash
export WINEPREFIX="$HOME/.vortex-linux/compatdata"

cd "$HOME/.vortex-linux/compatdata/drive_c/Program Files/Black Tree Gaming Ltd/Vortex" || exit 1

# Check for -d or -i with no "nxm" in the following argument
if [[ ("$1" == "-d" || "$1" == "-i") && "$2" != *"nxm"* ]]; then
  echo "No url provided, ignoring $1"
  exec ~/.pikdum/umu/umu-run Vortex.exe
else
  export PROTON_VERB="runinprefix"
  exec ~/.pikdum/umu/umu-run Vortex.exe "$@"
fi