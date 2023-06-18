# Pikdum's Steam Deck Tools

> **Notice:** Recently swapped Vortex install method from STL to [pikdum/vortex-linux](https://github.com/pikdum/vortex-linux).  
> This is a breaking change, so you'll need to uninstall + reinstall.  
> It's also completely new, so there might be bugs.  

## What is this

A Collection of tools and scripts for linux/steam-deck. 

Current Tools:
- Vortex Installer
- Vortex Fixes for linux/steamdeck

## Install

1. Right click and save as [this install.desktop link](https://github.com/SirStig/Steam-deck-tests/releases/download/Testing/Install-pikdums-tools.desktop)
2. Go to downloads folder and double click to run it

## Vortex Mod Manager

After installing, you should have a shortcut on the desktop to install vortex

This will:

0. Install SteamLinuxRuntime Sniper
1. Install pikdum/vortex-linux
2. Use ./vortex-linux to set up vortex
3. Add a 'Update Vortex Game Library' shortcut to desktop
   * Needs to be run every time after you install a new game you want to mod.
4. Add a 'Vortex Post Update' shortcut to desktop
   *Needs to be run after installing a "Mod Loader" or "Script Extender" to a game. List of supported games below.
5. Map J: to internal games and K: to sd card games
   * E: is the sd card root

After modding, run games normally through game mode rather than launching through vortex

#### Currently supported games that have Script Extenders:
1. Skyrim Special Edition
2. Skyrim Legendary Edition
3. Oblivion
4. Falllout 4
5. Fallout 3
6. Fallout New Vegas
* You can add more by adding them in the same format as the other games to the loaderlibrary.json file and creating a pull request.

### Adding a game

* Vortex will pop up some warnings about: staging location, deployment method
   * Walk through their fixes
   * Staging folder needs to be on the same drive as the game
     * Select the J:/ or E:/ drive which ever one has your game on it and create a vortex folder there for staging.
   * Deployment method should be hardlinks

### Download with vortex button link handler

> **Notice:** Heard some people mention that this requires Nexus Premium.  
> Could use some more people either confirming or denying this.  

* Might work out of the box, unless you've installed vortex before
* If it doesn't work, edit these lines in ~~`~/.local/share/applications/mimeapps.list`~~ `~/.config/mimeapps.list`
```
x-scheme-handler/nxm=vortex.desktop
x-scheme-handler/nxm-protocol=vortex.desktop
```
* Run `update-mime-database ~/.local/share/mime/`
* Might need to reboot
* If still issues, make sure your browser is using the default app

### What are the "Update Vortex Game Library", "Swap to Vanilla Launcher" & "Use Script Extender Launchers" desktop shortcut?

#### Update Vortex Game Library.desktop
This find's all the games on your device and basically connects folders that are needed for mods to be properly deployed and run on the games.
It also allows vortex to automatically find games installed on your device so you don't have to manually select the game folder.

#### Use Script Extender Launchers.desktop
This find's all installed games and checks for any Script Extender launchers, if found it will automatically change the name of the script extenders
.exe launcher to the same name as the games launcher and rename the games launcher to "_gamelauncher.exe".

#### Swap to Vanilla Launcher.desktop
This will find all the currently installed games that we know of that have different launchers for running mods, list them out for you and allow you to switch the
launcher back from the mod launcher to the normal vanilla one from the game.

Example:

SKSE64.exe and SkyrimSELauncher.exe

SKSE64 will be renamed to SkyrimSELauncher.exe
SkyrimSELauncher.exe will be renamed to _SkyrimSELauncher.exe

This simple change allows you to launch the games from steam or steam gamemode in the Steam Deck's case.

## Uninstall

```bash
# remove these tools
rm -rf ~/.pikdum/
# remove vortex
rm -rf ~/.vortex-linux/
rm -rf ~/.local/share/applications/vortex.*
# manually remove desktop icons
```

## Old version uninstall

```bash
# remove steamtinkerlaunch
rm -rf ~/stl/
rm -rf ~/.config/steamtinkerlaunch/
# remove these tools
rm -rf ~/.pikdum/
rm -rf ~/.local/share/applications/pikdum-vortex.desktop
```

