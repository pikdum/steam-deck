#!/usr/bin/env bash
set -euxo pipefail

# Check for umu-run via uv, if already setup by a previous run, skip installation
if ! $HOME/.local/bin/umu-run -h &> /dev/null; then # Direct check first, uv run adds complexity for a simple check
    echo "umu-launcher not found or not working, proceeding with installation..."

    # Install uv (if not already installed)
    if ! command -v uv &> /dev/null; then
        echo "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        # Source uv environment (path might vary depending on shell and OS)
        # Common locations for cargo/uv environment script
        if [ -f "$HOME/.cargo/env" ]; then
            source "$HOME/.cargo/env"
        elif [ -f "$HOME/.profile" ]; then
            source "$HOME/.profile" # May require relogin or new shell
        elif [ -f "$HOME/.bashrc" ]; then
            source "$HOME/.bashrc" # May require new shell
        else
            echo "Warning: Could not automatically source uv environment. Please ensure uv is in your PATH."
        fi
        # Verify uv is now available
        if ! command -v uv &> /dev/null; then
            echo "Failed to install or source uv. Please install uv manually and ensure it's in your PATH."
            exit 1
        fi
    fi

    UMU_VENV_DIR="$HOME/.local/share/umu-venv"
    UMU_RUN_SCRIPT_PATH="$HOME/.local/bin/umu-run"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$(dirname "$UMU_VENV_DIR")" # Ensure .local/share exists

    echo "Installing umu-launcher using uv..."
    uv venv "$UMU_VENV_DIR"
    # Use the uv binary from the venv to install into that venv
    "$UMU_VENV_DIR/bin/uv" pip install "umu-launcher"

    # Create the wrapper script $HOME/.local/bin/umu-run
    cat << EOF > "$UMU_RUN_SCRIPT_PATH"
#!/usr/bin/env sh
exec "$UMU_VENV_DIR/bin/umu-run" "\$@"
EOF
    chmod +x "$UMU_RUN_SCRIPT_PATH"

    # Verify installation
    if ! "$UMU_RUN_SCRIPT_PATH" -h &> /dev/null; then
        echo "Failed to install umu-launcher correctly."
        exit 1
    fi
    echo "umu-launcher installed successfully."
else
    echo "umu-launcher already installed and configured."
    UMU_RUN_SCRIPT_PATH="$HOME/.local/bin/umu-run" # Ensure it's defined
fi

export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx/"
mkdir -p "$WINEPREFIX"

VORTEX_VERSION="1.13.7"
PROTON_BUILD="GE-Proton9-23"

PROTON_URL="https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$PROTON_BUILD/$PROTON_BUILD.tar.gz"
VORTEX_INSTALLER="vortex-setup-$VORTEX_VERSION.exe"
VORTEX_URL="https://github.com/Nexus-Mods/Vortex/releases/download/v$VORTEX_VERSION/$VORTEX_INSTALLER"
DOTNET_URL="https://download.visualstudio.microsoft.com/download/pr/06239090-ba0c-46e2-ad3e-6491b877f481/c5e4ab5e344eb3bdc3630e7b5bc29cd7/windowsdesktop-runtime-6.0.21-win-x64.exe"

# install steam linux runtime sniper
steam steam://install/1628350

# The script is expected to be run from ~/.pikdum/steam-deck-master/vortex/
# as per install-vortex.desktop.in
# So, ensure this directory exists and cd into it.
TARGET_DIR="$HOME/.pikdum/steam-deck-master/vortex"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# Ensure vortex.sh is executable
chmod +x ./vortex.sh

# Download Vortex Installer
wget -O "$VORTEX_INSTALLER" "$VORTEX_URL"

# Download .NET Installer
wget -O "dotnet-installer.exe" "$DOTNET_URL"

# Install .NET Runtime
"$UMU_RUN_SCRIPT_PATH" "$(pwd)/dotnet-installer.exe" /q /norestart

# Install Vortex
"$UMU_RUN_SCRIPT_PATH" "$(pwd)/$VORTEX_INSTALLER" /S

# Create dosdevices directory and symlinks
mkdir -p "$WINEPREFIX/dosdevices"
cd "$WINEPREFIX/dosdevices"

if [ -d "$HOME/.steam/steam/steamapps/common/" ]; then
    ln -sfn "$HOME/.steam/steam/steamapps/common/" j: || true
fi

if [ -d "/run/media/mmcblk0p1/steamapps/common/" ]; then
    ln -sfn "/run/media/mmcblk0p1/steamapps/common/" k: || true
fi

# Change back to the script's directory for desktop file operations
cd "$TARGET_DIR"

# Copy the new .desktop file
cp ./vortex.desktop "$HOME/.local/share/applications/vortex.desktop"
update-desktop-database || true

# Update desktop shortcut
rm -f ~/Desktop/install-vortex.desktop
ln -sf ~/.local/share/applications/vortex.desktop ~/Desktop/Vortex.desktop

# Remove old game-specific deploy desktop symlinks (if they existed)
rm -f ~/Desktop/skyrim-post-deploy.desktop
rm -f ~/Desktop/skyrimle-post-deploy.desktop
rm -f ~/Desktop/fallout4-post-deploy.desktop
rm -f ~/Desktop/falloutnv-post-deploy.desktop
rm -f ~/Desktop/falloutnv-pre-deploy.desktop
rm -f ~/Desktop/fallout3-post-deploy.desktop
rm -f ~/Desktop/oblivion-post-deploy.desktop

# Create Vortex downloads directory on SD card if it exists
if [ -d "/run/media/mmcblk0p1/" ]; then
    mkdir -p "/run/media/mmcblk0p1/vortex-downloads" || true
fi

echo "Success! Exiting in 3..."
sleep 3
