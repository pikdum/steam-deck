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
   * E: is the sd card

after modding, run games normally through game mode rather than launching through vortex

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

