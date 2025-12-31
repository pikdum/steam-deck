{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, makeDesktopItem
, copyDesktopItems
, autoPatchelfHook
, wget
, unzip
, envsubst
, wine
, dotnet-runtime_6
, umu-launcher
, inetutils
, writeShellScriptBin
, makeWrapper
, findutils
, p7zip
}:

let
  steam-deck-master = fetchFromGitHub {
    owner = "pikdum";
    repo = "steam-deck";
    rev = "master";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # You'll need to update this
    fetchSubmodules = false;
  };

  vortex-version = "1.13.7";
  umu-version = "1.2.6";

  vortex-installer = fetchurl {
    url = "https://github.com/Nexus-Mods/Vortex/releases/download/v${vortex-version}/vortex-setup-${vortex-version}.exe";
    sha256 = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="; # Update this
  };

  dotnet-runtime = fetchurl {
    url = "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.36/windowsdesktop-runtime-6.0.36-win-x64.exe";
    sha256 = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC="; # Update this
  };

  umu-launcher-pkg = stdenv.mkDerivation rec {
    pname = "umu-launcher";
    version = umu-version;
    
    src = fetchurl {
      url = "https://github.com/Open-Wine-Components/umu-launcher/releases/download/${version}/umu-launcher-${version}-zipapp.tar";
      sha256 = "sha256-DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD="; # Update this
    };

    nativeBuildInputs = [ autoPatchelfHook ];

    installPhase = ''
      mkdir -p $out/bin
      tar --strip-components=1 -xf $src
      chmod +x umu-run
      cp umu-run $out/bin/
    '';
  };

  vortex-wrapper = writeShellScriptBin "vortex-wrapper" ''
    #!/usr/bin/env bash
    export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx"

    cd "$WINEPREFIX/drive_c/Program Files/Black Tree Gaming Ltd/Vortex" || exit 1

    if [[ ("$1" == "-d" || "$1" == "-i") && "$2" != *"nxm"* ]]; then
      echo "No url provided, ignoring $1"
      exec ${umu-launcher-pkg}/bin/umu-run Vortex.exe
    else
      export PROTON_VERB="runinprefix"
      exec ${umu-launcher-pkg}/bin/umu-run Vortex.exe "$@"
    fi
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "vortex";
      desktopName = "Vortex";
      exec = "${vortex-wrapper}/bin/vortex-wrapper %U";
      icon = "vortex";
      comment = "Mod manager for PC games";
      categories = [ "Game" "Utility" ];
      mimeTypes = [ "application/x-nexus-mod-manager" ];
    })
    # Add other desktop items for skyrim-post-deploy, etc. as needed
  ];

  postInstallScript = ''
    #!${stdenv.shell}
    set -euxo pipefail

    # Clean up data from old implementation
    rm -rf ~/.vortex-linux/proton-builds/
    rm -rf ~/.pikdum/steam-deck-master/vortex/vortex-linux

    echo "Templating files..."
    pushd ${steam-deck-master}
    find . -type f -name "*.in" -exec sh -c '${envsubst}/bin/envsubst < "$1" > "${1%.in}" && chmod +x "${1%.in}"' _ {} \;
    popd

    # Create desktop shortcuts
    ln -sf ${steam-deck-master}/update.desktop ~/Desktop/pikdum-update.desktop

    if [ ! -f "$HOME/.local/share/applications/vortex.desktop" ]; then
      echo "Creating Vortex install desktop shortcut..."
      ln -s ${steam-deck-master}/vortex/install-vortex.desktop ~/Desktop/install-vortex.desktop || true
    else
      # update .desktop file to make sure it's up to date
      cp ${steam-deck-master}/vortex/vortex.desktop ~/.local/share/applications/

      echo "Creating Vortex desktop shortcuts..."
      ln -sf ~/.local/share/applications/vortex.desktop ~/Desktop/
      ln -sf ${steam-deck-master}/vortex/skyrim-post-deploy.desktop ~/Desktop/
      ln -sf ${steam-deck-master}/vortex/skyrimle-post-deploy.desktop ~/Desktop/
      ln -sf ${steam-deck-master}/vortex/fallout4-post-deploy.desktop ~/Desktop/
      ln -sf ${steam-deck-master}/vortex/falloutnv-post-deploy.desktop ~/Desktop/
      ln -sf ${steam-deck-master}/vortex/fallout3-post-deploy.desktop ~/Desktop/
      ln -sf ${steam-deck-master}/vortex/oblivion-post-deploy.desktop ~/Desktop/

      echo "Vortex is already installed, updating umu-launcher..."
      ${steam-deck-master}/vortex/install-umu.sh
    fi

    MOUNTPOINT="$(findmnt /dev/mmcblk0p1 -o TARGET -n 2>/dev/null || echo "")"

    if [ -n "$MOUNTPOINT" ]; then
      mkdir -p $MOUNTPOINT/vortex-downloads || true
    fi
  '';

  installVortexScript = writeShellScriptBin "install-vortex" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    export WINEPREFIX="$HOME/.vortex-linux/compatdata/pfx"

    mkdir -p ~/.pikdum/steam-deck-master/vortex/
    cd ~/.pikdum/steam-deck-master/vortex/

    # Download Vortex installer
    cp ${vortex-installer} ./vortex-setup-${vortex-version}.exe

    # Install .NET runtime
    cp ${dotnet-runtime} ./dotnet-runtime.exe
    ${umu-launcher-pkg}/bin/umu-run dotnet-runtime.exe /q

    # Install Vortex
    ${umu-launcher-pkg}/bin/umu-run ./vortex-setup-${vortex-version}.exe /S

    # Create desktop file
    mkdir -p ~/.local/share/applications
    cp ${steam-deck-master}/vortex/vortex.desktop ~/.local/share/applications/

    # Set up drive letter mappings for Steam libraries
    cd "$WINEPREFIX/dosdevices"

    if [ -d "$HOME/.steam/steam/steamapps/common/" ]; then
      ln -s "$HOME/.steam/steam/steamapps/common/" j: || true
    fi

    MOUNTPOINT="$(findmnt /dev/mmcblk0p1 -o TARGET -n 2>/dev/null || echo "")"
    if [ -n "$MOUNTPOINT" ] && [ -d "$MOUNTPOINT/steamapps/common/" ]; then
      ln -s "$MOUNTPOINT/steamapps/common/" k: || true
    fi

    update-desktop-database || true

    rm -f ~/Desktop/install-vortex.desktop
    ln -sf ~/.local/share/applications/vortex.desktop ~/Desktop/
    ln -sf ${steam-deck-master}/vortex/skyrim-post-deploy.desktop ~/Desktop/
    ln -sf ${steam-deck-master}/vortex/skyrimle-post-deploy.desktop ~/Desktop/
    ln -sf ${steam-deck-master}/vortex/fallout4-post-deploy.desktop ~/Desktop/
    ln -sf ${steam-deck-master}/vortex/falloutnv-post-deploy.desktop ~/Desktop/
    ln -sf ${steam-deck-master}/vortex/falloutnv-pre-deploy.desktop ~/Desktop/
    ln -sf ${steam-deck-master}/vortex/fallout3-post-deploy.desktop ~/Desktop/
    ln -sf ${steam-deck-master}/vortex/oblivion-post-deploy.desktop ~/Desktop/

    if [ -n "$MOUNTPOINT" ]; then
      mkdir -p $MOUNTPOINT/vortex-downloads || true
    fi

    echo "Success! Exiting in 3..."
    sleep 3
  '';

  installScript = writeShellScriptBin "pikdum-install" ''
    #!/usr/bin/env bash
    set -euxo pipefail

    mkdir -p ~/.local/share/applications/

    mkdir -p ~/.pikdum
    cd ~/.pikdum
    cp -r ${steam-deck-master} ./steam-deck-master

    ${postInstallScript}

    echo "Success! Exiting in 3..."
    sleep 3
  '';

in stdenv.mkDerivation rec {
  pname = "steam-deck-vortex";
  version = "1.13.7";

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    wget
    unzip
    envsubst
    wine
    findutils
    inetutils
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/applications

    # Install scripts
    cp ${installScript}/bin/pikdum-install $out/bin/
    cp ${installVortexScript}/bin/install-vortex $out/bin/
    
    # Install umu-launcher
    mkdir -p $out/share/umu
    cp -r ${umu-launcher-pkg}/* $out/share/umu/
    ln -sf $out/share/umu/bin/umu-run $out/bin/umu-run

    # Install vortex wrapper
    cp ${vortex-wrapper}/bin/vortex-wrapper $out/bin/

    # Copy desktop files
    cp -r ${steam-deck-master}/vortex/*.desktop $out/share/applications/
    cp -r ${steam-deck-master}/update.desktop $out/share/applications/

    # Make all scripts executable
    chmod +x $out/bin/*
  '';

  postFixup = ''
    # Wrap binaries to ensure they have necessary dependencies
    wrapProgram $out/bin/vortex-wrapper \
      --prefix PATH : ${lib.makeBinPath [ umu-launcher-pkg wine findutils ]}
  '';

  desktopItems = desktopItems;

  meta = with lib; {
    description = "Vortex mod manager installer for Steam Deck";
    homepage = "https://github.com/pikdum/steam-deck";
    license = licenses.unfree; # Vortex itself is proprietary
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
}
