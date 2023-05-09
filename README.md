# pikdum's steam deck tools

> **Notice:** Vortex 1.8 is currently broken.  
> This will install Vortex 1.7.8, so make sure to turn off auto-updates afterwards if possible.  
> If already upgraded to 1.8 and it's broken, probably need to uninstall.

## what is this

a collection of steam deck tools and scripts to help automate some things, starting with installing vortex

## install

1. right click and save as [this install.desktop link](https://raw.githubusercontent.com/pikdum/steam-deck/master/install.desktop)
2. go to downloads folder and double click to run it

## vortex

after installing, you should have a shortcut on the desktop to install vortex

this will:
1. install steamtinkerlaunch
2. use steamtinkerlaunch to set up vortex
3. add Vortex as an application and allow it to open nexus urls
4. add a 'Skyrim Post-Deploy' shortcut to desktop
   * needs to be run every time after you change mods in Vortex

after modding, try and run games normally through game mode rather than launching through vortex

## uninstall

```bash
# remove steamtinkerlaunch
rm -rf ~/stl/
rm -rf ~/.config/steamtinkerlaunch/
# remove these tools
rm -rf ~/.pikdum/
rm -rf ~/.local/share/applications/pikdum-vortex.desktop
```
