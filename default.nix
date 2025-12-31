{ stdenvNoCC
, fetchurl
, writeShellScriptBin
, umu-launcher
, makeWrapper 
, substituteAll
, lib
}:
let
  vortexVersion = "1.13.7";

  vortexInstaller = fetchurl {
    url = "https://github.com/Nexus-Mods/Vortex/releases/download/v${vortexVersion}/vortex-setup-${vortexVersion}.exe";
    hash = lib.fakeSha256; # You'll need to update this
  };
  
  dotnetRuntime = fetchurl {
    url = "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.36/windowsdesktop-runtime-6.0.36-win-x64.exe";
    hash = lib.fakeSha256; # You'll need to update this
  };
  
  processedScript = substituteAll {
    src = ./post-install.sh;
    umuLauncher = umu-launcher;
    vortexInstaller = vortexInstaller;
    dotnetRuntime = dotnetRuntime;
  };
  
  # Create the final executable
  installScript = writeShellScriptBin "install-vortex" ''
    exec ${processedScript}
  '';

in stdenvNoCC.mkDerivation {
  pname = "vortex-setup";
  version = vortexVersion;
  
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ umu-launcher ];
  
  dontUnpack = true;
  dontBuild = true;
  
  installPhase = ''
    mkdir -p $out/bin
    cp ${installScript}/bin/install-vortex $out/bin/install-vortex
    
    wrapProgram $out/bin/install-vortex \
      --prefix PATH : ${stdenvNoCC.lib.makeBinPath [ umu-launcher ]}
  '';
  
  meta = with stdenvNoCC.lib; {
    description = "Vortex mod manager installer for Linux via umu-launcher";
    homepage = "https://github.com/Nexus-Mods/Vortex";
    license = licenses.unfree;
    maintainers = [];
    platforms = platforms.linux;
  };
}
