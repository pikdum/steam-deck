# pikdum's steam deck tools

> ⚠️ **Important:** After installing Vortex, you must manually disable auto-updates in Vortex settings and make sure it does **not** update to version **1.16+**.

## what is this

a collection of steam deck tools and scripts to help automate some things, starting with installing vortex

hopefully temporary solution until https://github.com/Nexus-Mods/NexusMods.App is ready

## install

1. right click and save as [this install.desktop link](https://raw.githubusercontent.com/pikdum/steam-deck/master/install.desktop)
2. go to the downloads folder, move the `install.desktop` file to the desktop, and double click to run it

or

``` bash
curl https://raw.githubusercontent.com/pikdum/steam-deck/master/install.sh | bash -s --
```

## vortex

after installing, you should have a shortcut on the desktop to install vortex

this will:

1. use umu to set up vortex
2. add a 'Skyrim Post-Deploy' shortcut to desktop
   * needs to be run every time after you change mods in Vortex
   * also adds a 'Fallout 4 Post-Deploy' and some others
3. map J: to internal games and K: to sd card games
   * E: is the sd card root

after modding, run games normally through game mode rather than launching through vortex

### adding a game

* will need to manually set the location, use either the J: or K: drives
  * J: is internal storage games, K: is sd card games
* vortex may pop up some warnings about: staging location, deployment method
   * if it does:
      * walk through their fixes
      * staging folder needs to be on the same drive as the game
        * suggested path works here
      * deployment method should be hardlinks
   * if it doesn't:
      * go to Settings -> Mods
      * set the **Base Path** to:
        * `K:\vortex_mods\{GAME}` if your games are on the sd card
        * `J:\vortex_mods\{GAME}` if your games are on the internal drive
      * press **Apply**
      * **Deployment Method** will now allow you to select `Hardlink deployment`
      * press **Apply** again

### download with vortex button link handler

* might work out of the box, unless you've installed vortex before
* if it doesn't work, edit these lines in ~~`~/.local/share/applications/mimeapps.list`~~ `~/.config/mimeapps.list`
```
x-scheme-handler/nxm=vortex.desktop
x-scheme-handler/nxm-protocol=vortex.desktop
```
* run `update-mime-database ~/.local/share/mime/`
* might need to reboot
* if still issues, make sure your browser is using the default app

### what are these post-deploy shortcuts?

these are for games that need a bit extra to get things working after modding in Vortex

they automate things like:

* copying required files from Vortex's Documents folder to the game's Documents folder
  * plugins.txt, loadorder.txt, etc.
* setting up script extenders to launch through Steam

a game's post-deploy script should be ran every time after modding in vortex

> **Note:** If you know what you're doing, could set up symlinks instead for this.  
> That way it only needs to be set up once, before starting modding.  
> Might evaluate refactoring to that approach in a v2.

### adding symlink instead of running post-deploy shortcuts

First navigate to ~/.vortex-linux/compatdata/pfx/drive_c/  
Then open a second tab and navigate to  ~/.local/share/Steam/steamapps/compatdata/<game_id>/pfx/drive_c/

To find the ID of a game, go to the Steam store page. The numbers after "app" in the url are the ID.  

Example for Skyrim SE:  
* URl: https://store.steampowered.com/app/489830/The_Elder_Scrolls_V_Skyrim_Special_Edition/  
* game_id: 489830  
* Path: ~/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/

Now take the "users" folder from the first location and move it to the second one.  
Overwrite when asked, some settings could be overwritten and you should launch the game once before modding.

Now in the first location, right click and go to create new>link to file or directory.  
Navigate back to ~/.local/share/Steam/steamapps/compatdata/<game_id>/pfx/drive_c/ and select the users folder.

Additional Steps:  

For Fallout 3:  
* Once you have installed FOSE, rename "Fallout3Launcher.exe" to "Fallout3Launcher.exe.old"  
* Then rename "fose_loader.exe" to "Fallout3Launcher.exe"  
* Now pressing play on Steam will use FOSE.

For Fallout NV:  
* Once you have installed NVSE, rename "FalloutNVLauncher.exe" to "FalloutNVLauncher.exe.old"  
* Then rename "nvse_loader.exe" to "FalloutNVLauncher.exe"  
* Now pressing play on Steam will use NVSE.

For Fallout 4:  
* Once you have installed F4SE, rename "Fallout4Launcher.exe" to "Fallout4Launcher.exe.old"  
* Then rename "f4se_loader.exe" to "Fallout4Launcher.exe"  
* Now pressing play on Steam will use F4SE.

For Oblivion:  
* Once you have installed OBSE, rename "OblivionLauncher.exe" to "OblivionLauncher.exe.old"  
* Then rename "obse_loader.exe" to "OblivionLauncher.exe"  
* Now pressing play on Steam will use SKSE.
    
For Skyrim LE:  
* Once you have installed SKSE, rename "SkyrimLauncher.exe" to "SkyrimLauncher.exe.old"  
* Then rename "skse_loader.exe" to "SkyrimLauncher.exe"  
* Now pressing play on Steam will use SKSE.
  
For Skyrim SE:  
* Once you have installed SKSE64, rename "SkyrimSELauncher.exe" to "SkyrimSELauncher.exe.old"  
* Then rename "skse64_loader.exe" to "SkyrimSELauncher.exe"  
* Now pressing play on Steam will use SKSE64.

IMPORTANT: After these steps you should never run the deploy shortcuts.

### how to open launcher to change settings afterwards

using Skyrim as an example:

* after running post-deploy, the game will now start SKSE instead of the launcher
* to open the launcher, install protontricks and launch the underscore-prefixed launcher .exe with it

## uninstall

```bash
# remove these tools
rm -rf ~/.pikdum/
# remove vortex
rm -rf ~/.vortex-linux/
rm -rf ~/.local/share/applications/vortex.*
# manually remove desktop icons
# uninstall umu proton builds/etc. if desired
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

