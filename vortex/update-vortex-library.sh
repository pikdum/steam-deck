#!/usr/bin/bash
VORTEX_PREFIX=~/.vortex-linux/compatdata/pfx;
printf "%s\n" "INFO: Using Vortex prefix at \"$VORTEX_PREFIX\"";
rmlink(){
    if [ -h "$1" ];
    then unlink "$1";
    fi;
}
mklink(){
    rmlink "$2";
    ln -s -T "$1" "$2";
}
manifest_attribute(){
    grep -a -o -e "\"$2\"[[:space:]]*\".*\"$" "$1" \
    | sed "s/\"$2\"[[:space:]]*\"//;s/\"$//";
};
manifest_userconfig_attribute(){
    manifest_attribute \
    <(grep \
        -a -o -P -z \
        "\"UserConfig\"\s*{(\s*[^}]*\s*)*}" \
        "$1"\
    ) "$2";
};
manifest_mountedconfig_attribute(){
    manifest_attribute \
    <(grep \
        -a -o -P -z \
        "\"MountedConfig\"\s*{(\s*[^}]*\s*)*}" \
        "$1"\
    ) "$2";
};
link_sub_targets(){
    TARGET="";
    DIR_LS=("$2"/*);
    for TARGET in "${DIR_LS[@]}"; do
        foldername="$(basename "$TARGET")";
        checklink="$1/$foldername";
        if [ "$foldername" != "Vortex" ] && \
        [ "$foldername" != "openvr" ] && \
        [ "$foldername" != "Microsoft" ] && \
        [ -d "$TARGET" ]; then
            if [ ! -L "$checklink" ]; then
               rm -dr "$checklink";
               ln -sf "$TARGET" "$1/";
            fi
        fi;
    done;
};
mkdir -p \
"$VORTEX_PREFIX/drive_c/users/steamuser/AppData/Roaming" \
"$VORTEX_PREFIX/drive_c/users/steamuser/AppData/Local" \
"$VORTEX_PREFIX/drive_c/users/steamuser/AppData/LocalLow" \
"$VORTEX_PREFIX/drive_c/users/steamuser/Documents/My Games" \
"$VORTEX_PREFIX/drive_c/users/steamuser/Local Settings" \
"$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/steamapps/common" \
"$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/config";
mklink \
"$VORTEX_PREFIX/drive_c/users/steamuser/AppData/Roaming" \
"$VORTEX_PREFIX/drive_c/users/steamuser/Application Data";
mklink \
"$VORTEX_PREFIX/drive_c/users/steamuser/AppData/Local" \
"$VORTEX_PREFIX/drive_c/users/steamuser/Local Settings/Application Data";
sed "s/\"\/.*\"$/\"C:\\\\\\\\Program Files \(x86\)\\\\\\\\Steam\"/g" < \
~/.steam/steam/steamapps/libraryfolders.vdf |& tee \
"$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/steamapps/libraryfolders.vdf" \
"$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/config/libraryfolders.vdf" \
1>/dev/null;
STEAM_LIBRARY_PATHS=();
while read -r library; do
    rmdir --ignore-fail-on-non-empty "$library"/steamapps/common/* 2>/dev/null;
    if [ -d "$library" ] && [ -d "$library/steamapps/common" ]; then
        if [ -d "$library/steamapps/compatdata/" ]; then
        STEAM_COMPATDATA=("$(find "$library/steamapps/compatdata/" -type d -name "pfx")");
        for compatdata in "${STEAM_COMPATDATA[@]}"; do
            rmdir --ignore-fail-on-non-empty "$compatdata" 2>/dev/null;
        done;
        fi;
        STEAM_LIBRARY_PATHS+=("$library");
    fi;
done < <(grep -a -o -e "/[^\"]*" ~/.steam/steam/steamapps/libraryfolders.vdf);
for library in "${STEAM_LIBRARY_PATHS[@]}"; do
    printf "%s\n" "INFO: Found Steam Library at \"$library\"! Linking all games in the library:";
    MANIFESTS=();
    readarray -t MANIFESTS < <(find "$library/steamapps" -mindepth 1 -maxdepth 1 -type f -name "appmanifest_*\.acf");
    for CURRENT_APPMANIFEST in "${MANIFESTS[@]}"; do
        CURRENT_APPID="$(manifest_attribute "$CURRENT_APPMANIFEST" "appid")";
        CURRENT_GAME="$(manifest_attribute "$CURRENT_APPMANIFEST" "name")";
        CURRENT_INSTALLDIR="$(manifest_attribute "$CURRENT_APPMANIFEST" "installdir")";
        printf "%s\n" \
        "INFO: \
        CURRENT_APPID=\"$CURRENT_APPID\" \
        CURRENT_GAME=\"$CURRENT_GAME\" \
        CURRENT_INSTALLDIR=\"$CURRENT_INSTALLDIR\"\
        ";
        checkdir="$(\
            printf "%s" "$CURRENT_APPMANIFEST" | \
            sed "s/\/steamapps\/.\+/\/steamapps\/common\//"\
        )$CURRENT_INSTALLDIR";
        if [ -d "$checkdir" ]; then
            CURRENT_INSTALL_PATH="$checkdir";
            checkdir="$(\
                printf "%s" "$CURRENT_APPMANIFEST" | \
                sed "s/\/steamapps\/.\+/\/steamapps\/compatdata\/$CURRENT_APPID\/pfx/"\
            )";
            printf "%s\n" \
            "GOOD: Found $CURRENT_GAME installation at \"$CURRENT_INSTALL_PATH\"";
            if [ "$(manifest_userconfig_attribute \
                    "$CURRENT_APPMANIFEST" \
                    "platform_override_dest"\
                )" == "linux" ] && \
            [ "$(manifest_userconfig_attribute \
                    "$CURRENT_APPMANIFEST" \
                    "platform_override_source"\
                )" == "windows" ];
            then
                printf "%s\n" \
                "INFO: platform_override_dest: \
                \"$(manifest_userconfig_attribute \
                    "$CURRENT_APPMANIFEST" \
                    "platform_override_dest"\
                )\" platform_override_source: \
                \"$(manifest_userconfig_attribute \
                    "$CURRENT_APPMANIFEST" \
                    "platform_override_source"\
                )\"\
                ";
                if [ -d "$checkdir" ]; then
                    CURRENT_PREFIX_PATH="$checkdir";
                    printf "%s\n" \
                        "GOOD: Found $CURRENT_GAME \
                        Proton Prefix at \
                        \"$CURRENT_PREFIX_PATH\"\
                    ";
                else
                    checkdir="${STEAM_LIBRARY_PATHS[0]}/steamapps/compatdata/$CURRENT_APPID/pfx";
                    printf "%s\n%s\n" \
                    "INFO: Proton Prefix for \
                    $CURRENT_GAME not found at \"$checkdir\"." \
                    "INFO: Trying \"$checkdir\" instead!";
                    if [ -d "$checkdir" ]; then
                        CURRENT_PREFIX_PATH="$checkdir";
                        printf "%s\n%s\n" \
                        "GOOD: Found $CURRENT_GAME Proton Prefix \
                        in default Steam Library at \
                        \"$CURRENT_PREFIX_PATH\"" \
                        "WARN: This feature should only be \
                        automatically used on a Steam Deck!";
                    else
                        CURRENT_PREFIX_PATH="";
                        printf "%s\n%s\n%s\n" \
                        "WARN: $CURRENT_GAME is configured for Proton but no Prefix was found!" \
                        "WARN: Its Proton Prefix is missing or has not been run yet!" \
                        "WARN: Launch the game with Proton via Steam before modding!";
                    fi;
                fi;
            elif [ -d "$checkdir" ]; then
                CURRENT_PREFIX_PATH="$checkdir";
                printf "%s\n%s\n" \
                "WARN: $CURRENT_GAME isn''t configured for Proton but a Prefix was found!" \
                "GOOD: Found $CURRENT_GAME Proton Prefix at \"$CURRENT_PREFIX_PATH\"";
            else
                CURRENT_PREFIX_PATH="";
                printf "%s\n" "INFO: No Proton Prefix for $CURRENT_GAME found!";
            fi;
        else
            CURRENT_INSTALL_PATH="";
            CURRENT_PREFIX_PATH="";
            checkdir="$CURRENT_INSTALL_PATH/steamapps/compatdata/$CURRENT_APPID/pfx";
            if [ -d "$checkdir" ]; then
            printf "%s\n%s\n" \
            "WARN: A Proton Prefix for $CURRENT_GAME exists at \"$checkdir\" but no installation was detected!" \
            "WARN: If $CURRENT_GAME was uninstalled, Steam may have left behind files, like save data it syncs with the Steam Cloud.";
            else
                printf "%s\n" "INFO: No installation or Proton Prefix of $CURRENT_GAME found!";
            fi;
        fi;
        if [ -d "$CURRENT_INSTALL_PATH" ]; then
            checkdir="$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/steamapps/common/$CURRENT_INSTALLDIR";
            rmlink "$checkdir";
            checkdir="$CURRENT_INSTALL_PATH";
            if [ -d "$checkdir" ]; then
                ln -s "$checkdir" "$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/steamapps/common/";
            fi;
            checkdir="$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/steamapps/appmanifest_$CURRENT_APPID.acf";
            rmlink "$checkdir";
            checkdir="$CURRENT_APPMANIFEST";
            if [ -f "$checkdir" ]; then
                ln -s "$checkdir" "$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/steamapps/";
            fi;
        fi;
        if [ -d "$CURRENT_PREFIX_PATH" ]; then
            link_sub_targets \
            "$VORTEX_PREFIX/drive_c/users/steamuser/Documents" \
            "$CURRENT_PREFIX_PATH/drive_c/users/steamuser/Documents";
            link_sub_targets \
            "$VORTEX_PREFIX/drive_c/users/steamuser/AppData/Roaming" \
            "$CURRENT_PREFIX_PATH/drive_c/users/steamuser/AppData/Roaming";
            link_sub_targets \
            "$VORTEX_PREFIX/drive_c/users/steamuser/AppData/Local" \
            "$CURRENT_PREFIX_PATH/drive_c/users/steamuser/AppData/Local";
            link_sub_targets \
            "$VORTEX_PREFIX/drive_c/users/steamuser/AppData/LocalLow" \
            "$CURRENT_PREFIX_PATH/drive_c/users/steamuser/AppData/LocalLow";
        fi;
    done;
done;
printf "%s\n" "DONE: Finished linking all detected Steam Library folders!";

printf "Going to sleep in 3...";

sleep 3
