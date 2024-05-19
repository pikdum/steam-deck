#!/usr/bin/env bash
set -euxo pipefail

# Overview: This script acts as a one time setup for supported games that are currently installed and managed through vortex
#           This will need to be ran anytime a game is installed and managed.
#           Supported games are listed in the constant "GAME_NAMES"

VORTEX_DATA_PATH="$HOME/.vortex-linux/compatdata/pfx/drive_c/users/steamuser/"
MAIN_STEAM_GAME_PATH="$HOME/.steam/steam/steamapps/"
ADDITIONAL_STORAGE_STEAM_PATH=(
    "/run/media/mmcblk0p1/steamapps/"
    )
STEAM_GAME_PATHS=("$MAIN_STEAM_GAME_PATH" "${ADDITIONAL_STORAGE_STEAM_PATH[@]}")

# ToDo: - Add more games to GAME_NAMES and the "Prepare Game Information" switch case and test them
#           (This script is built around Bethesda games. Other games likely wont be as easy to add)
#       - After tested well make a desktop symlink in "post-install.sh" for others to use

# This array of game name will be used with the "Prepare Game Information" switch case to run the same script for multiple games
GAME_NAMES=(
    "Fallout New Vegas"
    )

# If "uninstall" is passed in as an argument
script_behavior="${1:-"create"}"
[[ $script_behavior = "uninstall" ]] && undo_symlinks=true || undo_symlinks=false

# Color Echo Functions
# region Make echo messages colored for easier reading
NO_COLOR="\033[0m"

echo_success() {
    GREEN="\033[0;32m"
    echo -e "${GREEN}$1${NO_COLOR}"
}

echo_warning() {
    YELLOW="\033[1;33m"
    echo -e "${YELLOW}$1${NO_COLOR}"
}

echo_error() {
    RED="\033[0;31m"
    echo -e "${RED}$1${NO_COLOR}"
}

echo_info() {
    BLUE="\033[0;34m"
    echo -e "${BLUE}$1${NO_COLOR}"
}

# endregion

# Create Symlink Function
# region The source directory and symlink directory are prepared, then the symlink is created.
#        (Symlinks are files that redirect to another file) 
handle_symlink() {
    source_file_path=$1
    symlink_dir=$2
    symlink_name=$3
    symlink_path="${symlink_dir}$symlink_name"
    original_file_backup="${symlink_dir}_$symlink_name"

    # Make sure the file the symlink will point to exists and the directory for the symlink exists.
    if [ -f "$source_file_path" ] &&
        [ -d "$symlink_dir" ]; then

        # If the script is set to create the symlinks and one hasn't already been made, the symlink will be created.
        if [ "$undo_symlinks" = false ] && ! [ -h "$symlink_path" ]; then

            # If there is already a file with the symlink's name we rename the file before making the symlink
            if [ -f "$symlink_path" ]; then
                mv "$symlink_path" "$original_file_backup"
            fi

            # Create the symlink
            ln -sf "$source_file_path" "$symlink_path"
            echo_success "Made symlink for $source_file_path in $symlink_path"

        # If the script is set to remove the symlinks and one still exists, the symlink will be removed.
        #   Also if the original file still exists with a leading "_" it will be set back to the original name.
        elif [ "$undo_symlinks" = true ] && [ -h "$symlink_path" ]; then

            # Remove the symlink
            echo_success "Removed symlink for $source_file_path in $symlink_path"
            rm "$symlink_path"

            # If the original file still exists it will be set back to default.
            if [ -f "$original_file_backup" ]; then
                mv "$original_file_backup" "$symlink_path"
            fi
        else
            echo_info "No new symlink made for $source_file_path in $symlink_path"
        fi
    fi
}
#endregion


# Loop through each of the games defined in $GAME_NAMES
for game_name in "${GAME_NAMES[@]}"; do

    # Prepare Game Information
    # ToDo: Finish and test these (loadorder.txt & plugins.txt may not be the same with every game but haven't tested)
    # region This sets up the game specific data based on the game name defined in $GAME_NAMES
    case $game_name in
        # ToDo: Untested
        "Fallout 3")
            data_name="fallout3"
            script_ext="fose_loader.exe"
            default_launcher="Fallout3Launcher.exe"
            game_id="22370"
            ini_file_names=("FALLOUT.ini" "FalloutPrefs.ini")
            ;;
        # ToDo: Untested
        "Fallout 4")
            data_name="Fallout4"
            script_ext="f4se_loader.exe"
            default_launcher="Fallout4Launcher.exe"
            game_id="377160"
            ini_file_names=("Fallout4.ini" "Fallout4Prefs.ini")
            ;;
        "Fallout New Vegas")
            data_name="FalloutNV"
            script_ext="nvse_loader.exe"
            default_launcher="FalloutNVLauncher.exe"
            game_id="22380"
            ini_file_names=("Fallout.ini" "FalloutPrefs.ini")
            ;;
        # ToDo: Unfinished/Untested
        "Morrowind")
            data_name="$game_name"
            script_ext=".exe"
            default_launcher="Morrowind Launcher.exe"
            game_id="22320"
            ini_file_names=(".ini" ".ini")
            ;;
        # ToDo: Untested - Possibly missing an ini file
        "Oblivion")
            data_name="$game_name"
            script_ext="obse_loader.exe"
            default_launcher="OblivionLauncher.exe"
            game_id="22330"
            ini_file_names=("Oblivion.ini")
            ;;
        # ToDo: Untested
        "Skyrim Special Edition")
            data_name="$game_name"
            script_ext="skse64_loader.exe"
            default_launcher="SkyrimSELauncher.exe"
            game_id="489830"
            ini_file_names=("Skyrim.ini" "SkyrimPrefs.ini")
            ;;
        # ToDo: Untested
        "Skyrim")
            data_name="$game_name"
            script_ext="skse_loader.exe"
            default_launcher="SkyrimLauncher.exe"
            game_id="72850"
            ini_file_names=("Skyrim.ini" "SkyrimPrefs.ini")
            ;;
        # ToDo: Unfinished/Untested
        "Starfield")
            data_name="$game_name"
            script_ext="sfse_loader.exe"
            default_launcher=".exe"
            game_id="1716740"
            ini_file_names=(".ini" ".ini")
            ;;
        *) 
            echo_error "$game_name not properly added to 'new-game-setup.sh'"
            continue
            ;;
    esac
    # endregion

    # Creating Symlinks
    # region - Rename the default launcher by adding a leading "_" so that we don't remove it,
    #           then make a symlink to the script extender named as the default launcher.
    #           This makes it so that Steam launches the script extender instead of the default launcher
    #           and the symlink makes sure script extender updates dont require this to be ran again.
    #        - Set up symlinks so that and updates to games setup files from Vortex or the game itself 
    #           do not have to be managed separately.
    #           This is done for the ini files, as well as "loadorder.txt" & "plugins.txt".
    ini_path="Documents/My Games/$data_name/"
    appdata_path="AppData/Local/$data_name/"

    vortex_ini_data="${VORTEX_DATA_PATH}$ini_path"
    vortex_appdata_data="${VORTEX_DATA_PATH}$appdata_path"

    # region Look for vortex directories
    # endregion

    for steam_game_path in "${STEAM_GAME_PATHS[@]}"; do
        echo_success "$game_name: Working on symlinks for path: $steam_game_path"

        # Script Extender
        # region Validate path & Handle symlink for script extender to act as the games executable

        # region Handle sure the game's default location exists or move to the next game
        game_path="${steam_game_path}common/$game_name/"
        if ! [ -d "$game_path" ]; then
            echo_warning "Could not find $game_name in path: $game_path"
            continue
        fi
        echo_success "$game_name: Steam Game path found"
        # endregion

        # Handle symlink for script extender to act as the games executable
        handle_symlink "${game_path}$script_ext" "$game_path" "$default_launcher"
        echo_success "$game_name: Finished script extender symlink"
        # endregion

        # Data Files
        # region Set up symlinks for the games data files to the vortex files

        # region Handle sure the game's data location exists or move to the next game
        game_data_path="${steam_game_path}compatdata/$game_id/pfx/drive_c/users/steamuser/"
        if ! [ -d "$game_data_path" ]; then
            echo_warning "Could not find $game_name in path: $game_data_path"
            continue
        fi
        echo_success "$game_name: Steam Data path found"
        if ! [ -d "$vortex_ini_data" ]; then
            echo_error "$game_name: Can't find vital vortex directory for INI symlinks: $vortex_ini_data"
            continue
        fi
        if ! [ -d "$vortex_appdata_data" ]; then
            echo_error "$game_name: Can't find vital vortex directory for AppData symlinks: $vortex_appdata_data"
            continue
        fi
        echo_success "$game_name: Vortex Data paths found"
        # endregion

        # region Handle symlink(s) for .ini files
        ini_game_path="${game_data_path}$ini_path"
        for ini_file_name in "${ini_file_names[@]}"; do
            # The source of these symlinks has to be the ini files of game itself or the script extender will loop on launch
            handle_symlink "${ini_game_path}$ini_file_name" "$vortex_ini_data" "$ini_file_name"
        done
        echo_success "$game_name: Finished INI symlink(s)"
        # endregion

        # region Handle symlinks for game's loadorder.txt & plugins.txt
        appdata_game_path="${game_data_path}$appdata_path"
        handle_symlink "${vortex_appdata_data}loadorder.txt" "$appdata_game_path" "loadorder.txt"
        handle_symlink "${vortex_appdata_data}plugins.txt" "$appdata_game_path" "Plugins.txt"

        echo_success "$game_name: Finished AppData symlinks "
        # endregion

        #endregion

        echo_success "$game_name: Finished handling symlinks for path: $steam_game_path"
    done
    # endregion

done

sleep 3
