# pikdum's steam deck tools

## what is this

a collection of steam deck tools and scripts to help automate some things, starting with installing vortex

hopefully temporary solution until https://github.com/Nexus-Mods/NexusMods.App is ready

## Important Notes

- This project now uses `umu-launcher` (https://github.com/Open-Wine-Components/umu-launcher) to manage Vortex and its Wine/Proton environment.
- You must have `umu-launcher` installed and available in your system's PATH for the scripts to work correctly.
- The previous helper tool, `vortex-linux`, is no longer used.

## install

1. right click and save as [this install.desktop link](https://raw.githubusercontent.com/pikdum/steam-deck/master/install.desktop)
2. go to the downloads folder, move the `install.desktop` file to the desktop, and double click to run it

or

``` bash
curl https://raw.githubusercontent.com/pikdum/steam-deck/master/install.sh | bash -s --
```

## vortex

After installing, you should have a shortcut on the desktop to install Vortex. This installation is now managed by `umu-launcher`.

This process will:

0. Install SteamLinuxRuntime Sniper (as a dependency for some game setups, though Vortex itself runs via `umu-launcher`).
1. Download and install Vortex into the `$HOME/.vortex-linux/compatdata/pfx/` WINEPREFIX using `umu-launcher`.
2. Download and install the necessary .NET runtime into the same WINEPREFIX.
3. Create a `Vortex.desktop` file and a desktop shortcut to launch Vortex via `vortex-umu.sh` (which uses `umu-launcher`).
4. Add game-specific helper 'Post-Deploy' shortcuts to the desktop (e.g., 'Skyrim Post-Deploy').
   * These may still be necessary for certain games that require file copying after mod deployment.
5. Map J: to internal Steam library games and K: to SD card Steam library games within the Vortex WINEPREFIX.
   * E: is often the SD card root in other contexts, but for Vortex drive mappings, J: and K: are standard for game library locations.

After modding, run games normally through Steam in Game Mode rather than launching them through Vortex.

### adding a game

* Will need to manually set the game location within Vortex. Use either the J: or K: drives:
  * J: points to `~/.steam/steam/steamapps/common/` (internal storage games).
  * K: points to `/run/media/mmcblk0p1/steamapps/common/` (SD card games).
* Vortex may show warnings about staging location or deployment method.
   * If it does:
      * Follow the recommended fixes.
      * The staging folder must be on the same drive as the game.
        * A suggested path like `J:\vortex_mods\{GAME}` or `K:\vortex_mods\{GAME}` should work.
      * The deployment method should be "Hardlink deployment".
   * If it doesn't automatically prompt or you need to change it:
      * Go to Settings -> Mods.
      * Set the **Mod Staging Folder** (previously Base Path) to a path like:
        * `K:\vortex_mods\{GAME}` if your game is on the SD card (K: drive).
        * `J:\vortex_mods\{GAME}` if your game is on the internal drive (J: drive).
        * Ensure this directory is within the respective game drive (K: or J:).
      * Press **Apply**.
      * **Deployment Method** should now allow you to select `Hardlink deployment`.
      * Press **Apply** again.

### Download with Vortex button (NXM Link Handling)

* This should work out of the box as the `vortex.desktop` file installed to `~/.local/share/applications/` includes the necessary `MimeType` entries for `x-scheme-handler/nxm`.
* If it doesn't work, ensure your system's `mimeapps.list` (usually in `~/.config/mimeapps.list` or `~/.local/share/applications/mimeapps.list`) has lines like:
```
x-scheme-handler/nxm=vortex.desktop
```
* You might need to run `update-desktop-database ~/.local/share/applications` and `update-mime-database ~/.local/share/mime/`.
* A reboot or logging out and back in might be necessary.
* If issues persist, verify that your web browser is configured to use the system's default application for NXM links.

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

This is an advanced alternative to using the post-deploy shortcuts. It involves symlinking the game's user data directory from the Vortex WINEPREFIX to the game's actual Proton WINEPREFIX.

First, navigate to the Vortex WINEPREFIX user data location: `$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/` (or `My Documents/My Games/` depending on the game).
The exact path within Vortex's WINEPREFIX might vary based on the game (e.g., `My Documents/My Games/<GameName>`, or `AppData/Local/<GameName>`). You'll need to find where Vortex stores the game's modded configuration files (like `plugins.txt`).

Then open a second tab and navigate to the game's Proton WINEPREFIX, typically: `~/.local/share/Steam/steamapps/compatdata/<GAME_ID>/pfx/drive_c/users/steamuser/AppData/Local/` or `~/.local/share/Steam/steamapps/compatdata/<GAME_ID>/pfx/drive_c/users/steamuser/My Documents/My Games/`.

To find the `<GAME_ID>`:
1.  Open Steam.
2.  Go to the game's page in your library.
3.  Right-click the game, select "Properties..."
4.  In the "Updates" tab, you'll often see "App ID" or look at the store page URL.
    *   Example for Skyrim SE: URL is `https://store.steampowered.com/app/489830/...`, so `<GAME_ID>` is `489830`.
    *   The compatdata path would be `~/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/`.

The goal is to replace the game-specific configuration directory (e.g., `Skyrim Special Edition`) in the game's actual Proton prefix with a symlink to the version in Vortex's prefix.

**Example for Skyrim SE (AppData method):**
1.  Locate Skyrim SE's configuration in Vortex's prefix: `$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition`.
2.  Locate Skyrim SE's configuration in its Proton prefix: `~/.steam/steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition`.
3.  **Backup and remove** the original `Skyrim Special Edition` directory from the game's Proton prefix.
4.  Create a symlink in the game's Proton prefix pointing to the Vortex one:
    ```bash
    cd ~/.steam/steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/
    ln -s "$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition" .
    ```

**Important Considerations for Symlinking:**
*   This method requires careful path identification.
*   Some games might store files in `My Documents/My Games/` instead of `AppData/Local/`. Adjust paths accordingly.
*   **Always back up original directories before replacing them with symlinks.**
*   If done correctly, changes in Vortex (like plugin order) should immediately reflect in the game without running post-deploy scripts.
*   The old method of symlinking the entire `users` folder is too broad and can cause issues. Be specific to the game's configuration directory.

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
rm -rf "$HOME/.vortex-linux/compatdata/pfx/" # Corrected WINEPREFIX for umu-launcher setup
rm -rf ~/.local/share/applications/vortex.desktop # Main desktop file
rm -rf ~/.local/share/applications/vortex-umu.desktop # Old desktop file, if present
rm -rf ~/.config/vortex-linux/ # Old vortex-linux config
# remove vortex-linux data (no longer used, but good to clean up if present from old versions)
rm -rf ~/.vortex-linux/
rm -rf ~/.local/share/applications/vortex.* # Catch-all for any other vortex related desktop files
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

