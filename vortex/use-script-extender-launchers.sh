#!/usr/bin/bash
VORTEX_PREFIX=~/.vortex-linux/compatdata/pfx;
printf "%s\n" "UPDATE: Updating loaderlibrary.vdf to the most recent version";
rm -f ~/.pikdum/steam-deck-master/vortex/loaderlibrary.vdf
wget -q https://raw.githubusercontent.com/SirStig/Steam-deck-tests/main/vortex/loaderlibrary.vdf -P ~/.pikdum/steam-deck-master/vortex/
printf "%s\n" "INFO: Searching for all script extender launchers!";
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
    printf "%s\n" "INFO: Found Steam Library at \"$library\"";
    MANIFESTS=();
    readarray -t MANIFESTS < <(find "$library/steamapps" -mindepth 1 -maxdepth 1 -type f -name "appmanifest_*\.acf");
    for CURRENT_APPMANIFEST in "${MANIFESTS[@]}"; do
        CURRENT_APPID="$(manifest_attribute "$CURRENT_APPMANIFEST" "appid")";
        CURRENT_GAME="$(manifest_attribute "$CURRENT_APPMANIFEST" "name")";
        CURRENT_INSTALLDIR="$(manifest_attribute "$CURRENT_APPMANIFEST" "installdir")";
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
            "GOOD: Found $CURRENT_GAME";
            LOADERLIBRARY=~/.pikdum/steam-deck-master/vortex/loaderlibrary.vdf;
            declare -i ATTRIBUTE=0
            while read -r line; do
                LOADERGAMEID="$(manifest_attribute "$LOADERLIBRARY" "appid${ATTRIBUTE}")";
                LOADERLAUNCHER="$(manifest_attribute "$LOADERLIBRARY" "loader${ATTRIBUTE}")";
                GAMELAUNCHER="$(manifest_attribute "$LOADERLIBRARY" "launcher${ATTRIBUTE}")";
                ATTRIBUTE+=1;
                if [ "$LOADERGAMEID" == "$CURRENT_APPID" ]; then
                    printf "%s\n" "INFO: Discovered $CURRENT_GAME which uses $LOADERLAUNCHER to launch. Swapping .exe";
                    mv "$CURRENT_INSTALL_PATH/$GAMELAUNCHER" "$CURRENT_INSTALL_PATH/_${GAMELAUNCHER}";
                    cp "$CURRENT_INSTALL_PATH/$LOADERLAUNCHER" "$CURRENT_INSTALL_PATH/$GAMELAUNCHER";
                fi;
            done < $LOADERLIBRARY;
        fi;
    done;
done;



printf "%s\n" "DONE: Finished!";

printf "Going to sleep in 3...";

sleep 3
