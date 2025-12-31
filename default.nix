{ pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
}:
let
  vortexVersion = "1.13.7";

  vortexInstaller = builtins.fetchurl {
    url = "https://github.com/Nexus-Mods/Vortex/releases/download/v${vortexVersion}/vortex-setup-${vortexVersion}.exe";
    sha256 = "sha256:138i0ii5mnxh672nybr122cwwm6zqvinnifxqzjv84v13w35k61h";
  };
  
  dotnetInstaller = builtins.fetchurl {
    url = "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.36/windowsdesktop-runtime-6.0.36-win-x64.exe";
    sha256 = "sha256:0hc9g5xi4wdqx09g1sqphnpn8qvab7adkyr59z42p2zw4sxxw80d";
  };

  installScript = pkgs.replaceVars ./pre-install.sh {
    umuLauncher = "${pkgs.umu-launcher}";
    vortexInstaller = "${vortexInstaller}";
    dotnetInstaller = "${dotnetInstaller}";
  };


  preInstall = pkgs.writeShellScriptBin "vortex-install" ''
    exec ${installScript}
  '';
  
  vortexWrapperScript = pkgs.replaceVars ./vortex-wrapper.sh {
    umuLauncher = "${pkgs.umu-launcher}";
  };

  installPhaseScript = pkgs.replaceVars ./install-phase.sh {
    vortexWrapperScript = "${vortexWrapperScript}";
    desktopItem = "${./vortex.desktop}";
    desktopItemIcon = "${./vortex.ico}";
  };

in 
pkgs.stdenvNoCC.mkDerivation {
  pname = "vortex-setup";
  version = vortexVersion;
  
  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [ pkgs.umu-launcher ];
  
  dontUnpack = true;
  dontBuild = true;
  
  installPhase = ''
    runHook preInstall
    
    # Execute the install script
    bash ${installPhaseScript}
  '';
  
  meta = with lib; {
    description = "Vortex mod manager installer for Linux via umu-launcher";
    homepage = "https://github.com/Nexus-Mods/Vortex";
    license = licenses.unfree;
    maintainers = [];
    platforms = platforms.linux;
  };
}
