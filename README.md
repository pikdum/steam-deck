# pikdum's steam deck tools

> **Notice:** Recently swapped Vortex install method from STL to [pikdum/vortex-linux](https://github.com/pikdum/vortex-linux).  
> This is a breaking change, so you'll need to uninstall + reinstall.  
> It's also completely new, so there might be bugs.  

## what is this

a collection of steam deck tools and scripts to help automate some things, starting with installing vortex

## install

1. right click and save as [this install.desktop link](https://raw.githubusercontent.com/pikdum/steam-deck/master/install.desktop)
2. go to downloads folder and double click to run it

## vortex

after installing, you should have a shortcut on the desktop to install vortex

this will:

0. install SteamLinuxRuntime Sniper
1. install pikdum/vortex-linux
2. use ./vortex-linux to set up vortex
3. add a 'Skyrim Post-Deploy' shortcut to desktop
   * needs to be run every time after you change mods in Vortex
   * also adds a 'Fallout 4 Post-Deploy'
4. map J: to internal games and K: to sd card games
   * E: is the sd card root

after modding, run games normally through game mode rather than launching through vortex

### adding a game

* will need to manually set the location, use either the J: or K: drives
  * J: is internal storage games, K: is sd card games
* vortex will pop up some warnings about: staging location, deployment method
   * walk through their fixes
   * staging folder needs to be on the same drive as the game
     * suggested path works here
   * deployment method should be hardlinks

### download with vortex button link handler

> **Notice:** Heard some people mention that this requires Nexus Premium.  
> Could use some more people either confirming or denying this.  

* might work out of the box, unless you've installed vortex before
* if it doesn't work, edit these lines in `~/.local/share/applications/mimeapps.list`
```
x-scheme-handler/nxm=vortex.desktop
x-scheme-handler/nxm-protocol=vortex.desktop
```
* run `update-mime-database ~/.local/share/mime/`
* might need to reboot
* if still issues, make sure your browser is using the default app

## uninstall

```bash
# remove these tools
rm -rf ~/.pikdum/
# remove vortex
rm -rf ~/.vortex-linux/
rm -rf ~/.local/share/applications/vortex.*
# manually remove desktop icons
```

## old version uninstall

```bash
# remove steamtinkerlaunch
rm -rf ~/stl/
rm -rf ~/.config/steamtinkerlaunch/
# remove these tools
rm -rf ~/.pikdum/
rm -rf ~/.local/share/applications/pikdum-vortex.desktop
```

