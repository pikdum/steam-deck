#!/usr/bin/env bash
set -euxo pipefail

# --- Start of umu-launcher setup ---
UMU_VERSION="1.2.6"
UMU_SOURCE_DIR_NAME="umu-launcher-\$UMU_VERSION" # This is how it's named in the zip
UMU_INSTALL_PARENT_DIR="\$HOME/.local/share/umu-launcher-src"
UMU_TARGET_SOURCE_PATH="\$UMU_INSTALL_PARENT_DIR/\$UMU_SOURCE_DIR_NAME"
UMU_RUN_WRAPPER_PATH="\$HOME/.local/bin/umu-run"

# Check if our specific umu-run wrapper is already correctly set up
run_umu_setup=true
if [ -f "\$UMU_RUN_WRAPPER_PATH" ] && [ -x "\$UMU_RUN_WRAPPER_PATH" ]; then
    if "\$UMU_RUN_WRAPPER_PATH" -h &> /dev/null; then
        echo "umu-launcher (via uv script wrapper) already installed and configured."
        run_umu_setup=false
    else
        echo "umu-run wrapper found but not functional, attempting re-installation."
    fi
fi

if [ "\$run_umu_setup" = true ]; then
    echo "Setting up umu-launcher (version \$UMU_VERSION) using uv add --script..."

    if ! command -v uv &> /dev/null; then
        echo "Installing uv..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        if [ -f "\$HOME/.cargo/env" ]; then
            source "\$HOME/.cargo/env"
        elif [ -f "\$HOME/.profile" ]; then
            echo "Sourced uv from \$HOME/.profile. If uv not found, try opening a new terminal or re-login."
            source "\$HOME/.profile"
        elif [ -f "\$HOME/.bashrc" ]; then
            echo "Sourced uv from \$HOME/.bashrc. If uv not found, try opening a new terminal or re-login."
            source "\$HOME/.bashrc"
        else
            echo "Warning: Could not automatically source uv environment. Please ensure uv is in your PATH."
        fi
        if ! command -v uv &> /dev/null; then
            echo "Failed to install or source uv. Please install uv manually and ensure it's in your PATH."
            exit 1
        fi
    fi

    echo "Downloading umu-launcher source (v\$UMU_VERSION)..."
    rm -rf "\$UMU_INSTALL_PARENT_DIR"
    mkdir -p "\$UMU_INSTALL_PARENT_DIR"
    wget -O "\$UMU_INSTALL_PARENT_DIR/umu-launcher.zip" "https://github.com/Open-Wine-Components/umu-launcher/archive/refs/tags/v\$UMU_VERSION.zip"
    
    echo "Extracting umu-launcher source..."
    unzip -o "\$UMU_INSTALL_PARENT_DIR/umu-launcher.zip" -d "\$UMU_INSTALL_PARENT_DIR"
    if [ ! -d "\$UMU_TARGET_SOURCE_PATH" ]; then
        echo "Failed to extract umu-launcher source to \$UMU_TARGET_SOURCE_PATH."
        ls -la "\$UMU_INSTALL_PARENT_DIR"
        exit 1
    fi

    echo "Configuring umu-run script with uv..."
    pushd "\$UMU_TARGET_SOURCE_PATH"
    if [ ! -f "./umu-run" ]; then
       echo "umu-run script not found in \$UMU_TARGET_SOURCE_PATH. Touching it."
       touch ./umu-run
    fi
    chmod +x ./umu-run
    uv add --script ./umu-run 'python-xlib' 'urllib3' 'truststore'
    popd

    echo "Creating wrapper script at \$UMU_RUN_WRAPPER_PATH..."
    mkdir -p "\$(dirname "\$UMU_RUN_WRAPPER_PATH")"
    cat << EOF > "\$UMU_RUN_WRAPPER_PATH"
#!/usr/bin/env sh
exec uv run --cwd "\$UMU_TARGET_SOURCE_PATH" "\$UMU_TARGET_SOURCE_PATH/umu-run" "\$@"
EOF
    chmod +x "\$UMU_RUN_WRAPPER_PATH"

    if ! "\$UMU_RUN_WRAPPER_PATH" -h &> /dev/null; then
        echo "Failed to set up umu-launcher with uv correctly. Wrapper script might be non-functional."
        exit 1
    fi
    echo "umu-launcher (v\$UMU_VERSION) installed and configured successfully via uv script."
fi
# --- End of umu-launcher setup ---

export WINEPREFIX="\$HOME/.vortex-linux/compatdata/pfx/" # Use the same WINEPREFIX as vortex-linux for consistency
mkdir -p "\$WINEPREFIX"

VORTEX_VERSION="1.13.7" # Keep Vortex version
VORTEX_INSTALLER="vortex-setup-\$VORTEX_VERSION.exe"
VORTEX_URL="https://github.com/Nexus-Mods/Vortex/releases/download/v\$VORTEX_VERSION/\$VORTEX_INSTALLER"
DOTNET_URL="https://download.visualstudio.microsoft.com/download/pr/06239090-ba0c-46e2-ad3e-6491b877f481/c5e4ab5e344eb3bdc3630e7b5bc29cd7/windowsdesktop-runtime-6.0.21-win-x64.exe"

# install steam linux runtime sniper (still potentially useful for games)
steam steam://install/1628350

# The script is expected to be run from ~/.pikdum/steam-deck-master/vortex/
# as per install-vortex.desktop.in
# So, ensure this directory exists and cd into it.
TARGET_DIR="\$HOME/.pikdum/steam-deck-master/vortex"
mkdir -p "\$TARGET_DIR"
cd "\$TARGET_DIR"

# Ensure vortex.sh (the launcher script for Vortex itself) is executable
# This script (vortex.sh) should call the UMU_RUN_WRAPPER_PATH
if [ -f "./vortex.sh" ]; then
    chmod +x ./vortex.sh
else
    echo "Warning: ./vortex.sh not found. The Vortex application launcher might not work."
fi

# Download Vortex Installer
echo "Downloading Vortex installer..."
wget -O "\$VORTEX_INSTALLER" "\$VORTEX_URL"

# Download .NET Installer
echo "Downloading .NET runtime installer..."
wget -O "dotnet-installer.exe" "\$DOTNET_URL"

# Install .NET Runtime using umu-run wrapper
echo "Installing .NET runtime..."
"\$UMU_RUN_WRAPPER_PATH" "\$(pwd)/dotnet-installer.exe" /q /norestart

# Install Vortex using umu-run wrapper
echo "Installing Vortex..."
"\$UMU_RUN_WRAPPER_PATH" "\$(pwd)/\$VORTEX_INSTALLER" /S

# Create dosdevices directory and symlinks
echo "Setting up WINEPREFIX dosdevices symlinks..."
mkdir -p "\$WINEPREFIX/dosdevices"
cd "\$WINEPREFIX/dosdevices"

if [ -d "$HOME/.steam/steam/steamapps/common/" ]; then
    ln -s "$HOME/.steam/steam/steamapps/common/" j: || true
fi

if [ -d "/run/media/mmcblk0p1/steamapps/common/" ]; then
    ln -s "/run/media/mmcblk0p1/steamapps/common/" k: || true
fi

update-desktop-database || true

rm -f ~/Desktop/install-vortex.desktop
ln -sf "\$HOME/.local/share/applications/vortex.desktop" "\$HOME/Desktop/Vortex.desktop" # Link to Vortex.desktop specifically
# Copy the vortex.desktop file to applications
# Assuming vortex.desktop is in TARGET_DIR and correctly configured
if [ -f "\$TARGET_DIR/vortex.desktop" ]; then
    cp "\$TARGET_DIR/vortex.desktop" "\$HOME/.local/share/applications/vortex.desktop"
else
    echo "Warning: \$TARGET_DIR/vortex.desktop not found. Application menu shortcut might not be created."
fi
# update-desktop-database should be called after cp
update-desktop-database "\$HOME/.local/share/applications" || true


# Remove old game-specific deploy desktop symlinks (if they existed)
rm -f "\$HOME/Desktop/skyrim-post-deploy.desktop"
rm -f "\$HOME/Desktop/skyrimle-post-deploy.desktop"
rm -f "\$HOME/Desktop/fallout4-post-deploy.desktop"
rm -f "\$HOME/Desktop/falloutnv-post-deploy.desktop"
rm -f "\$HOME/Desktop/falloutnv-pre-deploy.desktop"
rm -f "\$HOME/Desktop/fallout3-post-deploy.desktop"
rm -f "\$HOME/Desktop/oblivion-post-deploy.desktop"

# Create Vortex downloads directory on SD card if it exists
if [ -d "/run/media/mmcblk0p1/" ]; then
    mkdir -p "/run/media/mmcblk0p1/vortex-downloads" || true
fi

echo "Success! Exiting in 3..."
sleep 3
