#!/bin/sh

# Anpassbare Variablen
DIRECTORY="$PWD"
SCREENAME='example'
MIN_RAM="1G"
MAX_RAM="2G"
START_CONSOLE=true
AUTO_UPDATE=true

# Farben
COL_WHITE="\033[1;37m"
COL_RED="\033[0;31m"
COL_LIGHT_RED="\033[1;31m"
COL_CYAN="\033[0;36m"
COL_GRAY="\033[1;30m"



clear
cd "$DIRECTORY"


check_update() {

    if $AUTO_UPDATE; then

        new_version=$(wget -qO- https://raw.githubusercontent.com/FetzerTony/startupScript-Minecraft-V2/main/version.txt)
        if [ "$SCRIPT_VERSION" \< "$new_version" ]; then
            echo " "
            echo "Neue Version verfügbar: ${COL_CYAN}$new_version"
            echo "${COL_WHITE}Aktuelle Version: ${COL_CYAN}$SCRIPT_VERSION"
            echo " "
            update() {
                echo "Möchtest du die neuste Version installieren? (${COL_CYAN}y/n${COL_WHITE})"
                read answer
                answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
                case $answer in
                    "y"|"yes")
                        echo " "
                        echo "Die neuste Version wird heruntergeladen."
                        echo "Das Script muss anschließend neu gestartet werden."
                        echo "${COL_GRAY}"
                        sleep 2

                        latest_release=$(wget -qO- https://api.github.com/repos/FetzerTony/startupScript-Minecraft-V2/releases/latest)
                        download_link=$(echo "$latest_release" | grep browser_download_url | grep start-de.sh | cut -d '"' -f 4)
                        wget "$download_link" -O start.sh

                        echo "${COL_WHITE}"
                        exit 0
                        ;;
                    "n"|"no")
                        echo " "
                        echo "Die neuste Version wird nicht heruntergeladen."
                        ;;
                    *)
                        echo "Ungültige Eingabe!"
                        update
                        ;;
                esac
            }

            update
        fi
    fi
}



check_first_run() {
    CONFIRMATION=false

    # Checking for server.jar
    if [ ! -e server.jar ]
    then
        echo ''${COL_LIGHT_RED}'        _____ _             _                     _____           _       _   '
        echo '       / ____| |           | |                   / ____|         (_)     | |  '
        echo '      | (___ | |_ __ _ _ __| |_ _   _ _ __ _____| (___   ___ _ __ _ _ __ | |_ '
        echo '       \___ \| __/ _` | '__\''| __| | | | '\''_ \______\___ \ / __| '\''__| | '\''_ \| __|'
        echo '       ____) | || (_| | |  | |_| |_| | |_) |     ____) | (__| |  | | |_) | |_ '
        echo '      |_____/ \__\__,_|_|   \__|\__,_| .__/     |_____/ \___|_|  |_| .__/ \__|'
        echo '                                     | |                           | |        '
        echo '                                     |_|                           |_|        '
        echo " "
        echo "${COL_CYAN}[INFO] ${COL_GRAY}Das Script wurde zum ersten mal gestartet und es existiert keine server.jar"
        echo "${COL_WHITE}Herzlich Willkommen zur Server-Konfiguration. Du kannst jederzeit mit CTRL + C abbrechen"
        echo " "

        CONFIRMATION=true
        SOFTWARE=
        VERSION=


        config_software() {
            echo "Welche Software möchtest du installieren? (${COL_CYAN}Spigot|Paper|Vanilla|CraftBukkit|Fabric|Bungeecord${COL_WHITE})"
            read answer
            answer=$(echo $answer | tr '[:upper:]' '[:lower:]')

            case $answer in
                "spigot"|"paper"|"vanilla"|"craftbukkit"|"fabric"|"bungeecord")
                    echo "${COL_CYAN}${answer} ${COL_WHITE}wurde als Software ausgewählt."
                    SOFTWARE="${answer}"
                    ;;
                *)
                    echo "Ungültige Eingabe!"
                    config_software
                    ;;
            esac
        }

        config_software


        if [ "${SOFTWARE}" != "bungeecord" ]
        then
            config_version() {
                echo " "
                echo "Welche Version möchtest du installieren? (${COL_GRAY}Bsp. 1.19.2${COL_WHITE})"
                read answer
                echo "${COL_CYAN}${answer} ${COL_WHITE}wurde als Version ausgewählt."
                VERSION="${answer}"
            }

            config_version
        fi


        
    fi


    if [ "${SOFTWARE}" != "bungeecord" ]
    then
        # Checking for Eula (when Spigot, Sponge, Paper, Bukkit)
        if [ ! -e eula.txt ] || [ ! "$(grep -c 'eula=true' eula.txt)" -eq 1 ] && [ "${SOFTWARE}" != "Bungeecord" ]; then
                config_eula() {
                    echo " "
                    echo "Akzeptierst du die Eula? (${COL_CYAN}y/n${COL_WHITE})"
                    read answer
                    answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
                    case $answer in
                        "y"|"yes")
                            echo "Die Eula wurde akzeptiert."
                            EULA=true
                            CONFIRMATION=true
                            ;;
                        "n"|"no")
                            echo "Die Eula wurde nicht akzeptiert und der Vorgang abgebrochen."
                            exit 1
                            ;;
                        *)
                            echo "Ungültige Eingabe!"
                            config_eula
                            ;;
                    esac
                }

                config_eula
        fi
    fi


    # Checking for screen
    if [ ! -x "$(command -v screen)" ]; then
        config_screen() {
                echo " "
                echo "screen ist nicht installiert. Möchtest du screen installieren? (${COL_CYAN}y/n${COL_WHITE})"
                read answer
                answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
                    case $answer in
                    "y"|"yes")
                        echo "screen wird installiert."
                        SCREEN=true
                        CONFIRMATION=true
                        ;;
                    "n"|"no")
                        echo "Screen wird nicht installiert und der Vorgang abgebrochen."
                        exit 1
                        ;;
                    *)
                        echo "Ungültige Eingabe!"
                        config_screen
                        ;;
                esac
        }

        config_screen
    fi






    # Konfiguration Bestätigung
    confirm() {
        if $CONFIRMATION; then
            echo " "
            echo "Bestätigst du deine Konfiguration? (${COL_CYAN}y/n${COL_WHITE})"
            read answer
            answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
            case $answer in
                "y"|"yes")
                    echo "Der Server wird nun eingerichtet, dies kann einen Moment dauern. Sie werden in die Konsole weitergeleitet..."

                    if ${EULA}; then
                        echo "eula=true" > eula.txt
                        echo "${COL_CYAN}[INFO] ${COL_GRAY}Eula wurde auf true gesetzt"
                    fi

                    if ${SCREEN}; then
                        sudo apt-get update
                        sudo apt-get install screen
                        echo "${COL_CYAN}[INFO] ${COL_GRAY}Screen wurde installiert"
                    fi

                    case $SOFTWARE in
                        "bungeecord")
                            echo "${COL_CYAN}[INFO] ${COL_GRAY}Bungeecord wird installiert"

                            url="https://ci.md-5.net/job/BungeeCord/lastSuccessfulBuild/artifact/bootstrap/target/BungeeCord.jar"
                            filename=$(basename "$url")
                            wget "$url" -O "server.jar"
                            touch "${filename}.info"
                            ;;
                        "spigot")
                            url_1="https://download.getbukkit.org/spigot/spigot-${VERSION}.jar"
                            url_2="https://cdn.getbukkit.org/spigot/spigot-${VERSION}.jar"
                            url_3="https://cdn.getbukkit.org/spigot/spigot-${VERSION}-R0.1-SNAPSHOT-latest.jar"
                            

                            if [ ! -e server.jar ]; then
                                wget "${url_1}" -O server.jar

                                if [ -e server.jar ]; then
                                    filename=$(basename "$url_1")
                                    size=$(stat -c%s "server.jar")
                                    if [ "$size" -ge 10000000 ]; then
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar wurde installiert. (url_1)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar nicht korrekt. (url_1)"
                                        rm "server.jar"
                                    fi
                                fi
                            fi

                            if [ ! -e server.jar ]; then
                                wget "${url_2}" -O server.jar

                                if [ -e server.jar ]; then
                                    filename=$(basename "$url_2")
                                    size=$(stat -c%s "server.jar")
                                    if [ "$size" -ge 10000000 ]; then
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar wurde installiert. (url_2)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar nicht korrekt. (url_2)"
                                        rm "server.jar"
                                    fi
                                fi
                            fi

                            if [ ! -e server.jar ]; then
                                wget "${url_3}" -O server.jar

                                if [ -e server.jar ]; then
                                    filename=$(basename "$url_3")
                                    size=$(stat -c%s "server.jar")
                                    if [ "$size" -ge 10000000 ]; then
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar wurde installiert. (url_3)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar nicht korrekt. (url_3)"
                                        rm "server.jar"
                                        echo " "
                                        echo "${COL_RED}[WARNUNG] ${COL_WHITE}Spigot ${VERSION} konnte nicht gefunden werden. Falls die Version doch verfügbar ist, gehe bitte wie folgt vor"
                                        echo "  ${COL_CYAN}1. ${COL_WHITE}Lade die Version herunter."
                                        echo "  ${COL_CYAN}2. ${COL_WHITE}Packe sie in den Server-Ordner."
                                        echo "  ${COL_CYAN}3. ${COL_WHITE}Benne die Datei zu ${COL_CYAN}server.jar ${COL_WHITE}um."
                                        echo "  ${COL_CYAN}Optional: ${COL_WHITE}Erstelle eine .info Datei mit dem Namen der Datei. (z.B. spigot-1.19.2.jar)"
                                        exit 1
                                    fi
                                fi
                            fi
                            ;;
                        "paper")
                            # Checking for jq
                            if [ ! -x "$(command -v jq)" ]; then
                                install_jq() {
                                        echo "${COL_WHITE} "
                                        echo "jq ist nicht installiert. Möchtest du jq installieren? (${COL_CYAN}y/n${COL_WHITE})"
                                        read answer
                                        answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
                                            case $answer in
                                            "y"|"yes")
                                                echo "jq wird installiert."
                                                echo "${COL_GRAY}"
                                                sudo apt-get update
                                                sudo apt-get install jq
                                                echo "${COL_CYAN}[INFO] ${COL_GRAY}jq wurde installiert."
                                                ;;
                                            "n"|"no")
                                                echo "jq wird nicht installiert und der Vorgang abgebrochen."
                                                exit 1
                                                ;;
                                            *)
                                                echo "Ungültige Eingabe!"
                                                install_jq
                                                ;;
                                        esac
                                }

                                install_jq
                            fi

                            api="https://papermc.io/api/v2"
                            name="paper"
                            # Get the build number of the most recent build
                            latest_build="$(curl -sX GET "$api"/projects/"$name"/versions/"$VERSION"/builds -H 'accept: application/json' | jq '.builds [-1].build')"
                            
                            temp="$(curl -sX GET "$api"/projects/"$name"/versions/"$VERSION"/builds -H 'accept: application/json' | jq '.builds [-1].version')"
                            temp="${temp%\"}"
                            version="${temp#\"}"
                            
                            # Construct download URL
                            url="$api"/projects/"$name"/versions/"$VERSION"/builds/"$latest_build"/downloads/"$name"-"$VERSION"-"$latest_build".jar

                            filename=$(basename "$url")
                            wget "${url}" -O server.jar
                            size=$(stat -c%s "server.jar")
                            if [ -e server.jar ] && [ "$size" -ge 10000000 ]; then
                                    echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar wurde installiert."
                                    touch "${filename}.info"
                                else
                                    echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar konnte nicht installiert werden."
                                    rm "server.jar"
                                    echo " "
                                    echo "${COL_RED}[WARNUNG] ${COL_WHITE}Paper ${VERSION} konnte nicht gefunden werden. Falls die Version doch verfügbar ist, gehe bitte wie folgt vor"
                                    echo "  ${COL_CYAN}1. ${COL_WHITE}Lade die Version herunter."
                                    echo "  ${COL_CYAN}2. ${COL_WHITE}Packe sie in den Server-Ordner."
                                    echo "  ${COL_CYAN}3. ${COL_WHITE}Benne die Datei zu ${COL_CYAN}server.jar ${COL_WHITE}um."
                                    echo "  ${COL_CYAN}Optional: ${COL_WHITE}Erstelle eine .info Datei mit dem Namen der Datei. (z.B. paper-1.19.2-396.jar)"
                                    exit 1
                                fi
                            ;;
                        "craftbukkit")
                            url_1="https://download.getbukkit.org/craftbukkit/craftbukkit-${VERSION}.jar"
                            url_2="https://cdn.getbukkit.org/craftbukkit/craftbukkit-${VERSION}.jar"
                            url_3="https://cdn.getbukkit.org/craftbukkit/craftbukkit-${VERSION}-R0.1-SNAPSHOT-latest.jar"
                            url_4="https://cdn.getbukkit.org/craftbukkit/craftbukkit-${VERSION}-R0.1-SNAPSHOT.jar"
                            

                            if [ ! -e server.jar ]; then
                                wget "${url_1}" -O server.jar

                                if [ -e server.jar ]; then
                                    filename=$(basename "$url_1")
                                    size=$(stat -c%s "server.jar")
                                    if [ "$size" -ge 10000000 ]; then
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar wurde installiert. (url_1)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar nicht korrekt. (url_1)"
                                        rm "server.jar"
                                    fi
                                fi
                            fi

                            if [ ! -e server.jar ]; then
                                wget "${url_2}" -O server.jar

                                if [ -e server.jar ]; then
                                    filename=$(basename "$url_2")
                                    size=$(stat -c%s "server.jar")
                                    if [ "$size" -ge 10000000 ]; then
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar wurde installiert. (url_2)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar nicht korrekt. (url_2)"
                                        rm "server.jar"
                                    fi
                                fi
                            fi

                            if [ ! -e server.jar ]; then
                                wget "${url_3}" -O server.jar

                                if [ -e server.jar ]; then
                                    filename=$(basename "$url_3")
                                    size=$(stat -c%s "server.jar")
                                    if [ "$size" -ge 10000000 ]; then
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar wurde installiert. (url_3)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar nicht korrekt. (url_3)"
                                        rm "server.jar"
                                    fi
                                fi
                            fi

                            if [ ! -e server.jar ]; then
                                wget "${url_4}" -O server.jar

                                if [ -e server.jar ]; then
                                    filename=$(basename "$url_4")
                                    size=$(stat -c%s "server.jar")
                                    if [ "$size" -ge 10000000 ]; then
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar wurde installiert. (url_4)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar nicht korrekt. (url_4)"
                                        rm "server.jar"
                                        echo " "
                                        echo "${COL_RED}[WARNUNG] ${COL_WHITE}CraftBukkit ${VERSION} konnte nicht gefunden werden. Falls die Version doch verfügbar ist, gehe bitte wie folgt vor"
                                        echo "  ${COL_CYAN}1. ${COL_WHITE}Lade die Version herunter."
                                        echo "  ${COL_CYAN}2. ${COL_WHITE}Packe sie in den Server-Ordner."
                                        echo "  ${COL_CYAN}3. ${COL_WHITE}Benne die Datei zu ${COL_CYAN}server.jar ${COL_WHITE}um."
                                        echo "  ${COL_CYAN}Optional: ${COL_WHITE}Erstelle eine .info Datei mit dem Namen der Datei. (z.B. craftbukkit-1.19.2.jar)"
                                        exit 1
                                    fi
                                fi
                            fi
                            ;;
                        "fabric")
                            fabric_version="0.14.14"
                            installer_version="0.11.1"

                            url="https://meta.fabricmc.net/v2/versions/loader/${VERSION}/${fabric_version}/${installer_version}/server/jar"

                            wget "${url}" -O server.jar
                            size=$(stat -c%s "server.jar")
                            if [ -e server.jar ] && [ "$size" -ge 100000 ]; then
                                    echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar wurde installiert."
                                    touch "fabric-${VERSION}.jar.info"
                                else
                                    echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar konnte nicht installiert werden"
                                    rm "server.jar"
                                    echo " "
                                    echo "${COL_RED}[WARNUNG] ${COL_WHITE}Fabric ${VERSION} konnte nicht gefunden werden. Falls die Version doch verfügbar ist, gehe bitte wie folgt vor"
                                    echo "  ${COL_CYAN}1. ${COL_WHITE}Lade die Version herunter."
                                    echo "  ${COL_CYAN}2. ${COL_WHITE}Packe sie in den Server-Ordner."
                                    echo "  ${COL_CYAN}3. ${COL_WHITE}Benne die Datei zu ${COL_CYAN}server.jar ${COL_WHITE}um."
                                    echo "  ${COL_CYAN}Optional: ${COL_WHITE}Erstelle eine .info Datei mit dem Namen der Datei. (z.B. fabric-1.19.3.jar)"
                                    exit 1
                                fi
                            ;;
                        "vanilla")
                            raw_download="https://raw.githubusercontent.com/FetzerTony/startupScript-Minecraft-V2/main/downloads.txt"
                            wget "${raw_download}" -O downloads.txt
                            if grep -q "^$VERSION " downloads.txt; then
                                # If it exists, extract the download link and save it as the DOWNLOAD_LINK variable
                                download_link=$(grep "^$VERSION " downloads.txt | cut -d' ' -f2)
                                wget "${download_link}" -O server.jar
                                touch "Vanilla-${VERSION}.jar.info"
                                echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar wurde installiert."
                                rm downloads.txt
                            else
                                echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar konnte nicht installiert werden"
                                echo " "
                                echo "${COL_RED}[WARNUNG] ${COL_WHITE}Vanilla ${VERSION} konnte nicht gefunden werden. Falls die Version doch verfügbar ist, gehe bitte wie folgt vor"
                                echo "  ${COL_CYAN}1. ${COL_WHITE}Lade die Version herunter."
                                echo "  ${COL_CYAN}2. ${COL_WHITE}Packe sie in den Server-Ordner."
                                echo "  ${COL_CYAN}3. ${COL_WHITE}Benne die Datei zu ${COL_CYAN}server.jar ${COL_WHITE}um."
                                echo "  ${COL_CYAN}Optional: ${COL_WHITE}Erstelle eine .info Datei mit dem Namen der Datei. (z.B. Vanilla-1.19.3.jar)"
                                rm downloads.txt
                                exit 1
                            fi
                            ;;
                    esac

                    echo "${COL_WHITE}"
                    ;;
                "n"|"no")
                    echo "Die Konfiguration wurde abgebrochen."
                    exit 1
                    ;;
                *)
                    echo "Ungültige Eingabe!"
                    confirm
                    ;;
            esac
        fi
    }
    confirm
}


check_self_test() {
    # Checking for screen
    if [ ! -x "$(command -v screen)" ]; then
        config_screen() {
                echo " "
                echo "screen ist nicht installiert. Möchtest du screen installieren? (${COL_CYAN}y/n${COL_WHITE})"
                read answer
                answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
                    case $answer in
                    "y"|"yes")
                        echo "screen wird installiert."
                        echo "${COL_GRAY}"
                        sudo apt-get install screen
                        echo "${COL_WHITE}"
                        ;;
                    "n"|"no")
                        echo "Screen wird nicht installiert und der Vorgang abgebrochen."
                        exit 1
                        ;;
                    *)
                        echo "Ungültige Eingabe!"
                        config_screen
                        ;;
                esac
        }

        config_screen
    fi
}

run() {
    echo " "
    echo "${COL_WHITE}Welche Aktion möchtest du ausführen: (${COL_CYAN}start, stop, restart, view, kill, info, update, version, exit${COL_WHITE})"
    read arg
    arg=$(echo $arg | tr '[:upper:]' '[:lower:]')
    case $arg in
        "start")
            if ! screen -list | grep -q ${SCREENAME} ; then
                screen -d -m -S ${SCREENAME} java -Xmx${MAX_RAM} -Xms${MIN_RAM} -XX:+UseG1GC -jar server.jar nogui
                if $START_CONSOLE; then
                    echo " "
                    echo "Der Server wird gestartet. Du wirst in 3 Sekunden in die Konsole weitergeleitet..."
                    echo "${COL_RED}WICHTIG: ${COL_WHITE}Verlasse die Konsole mit ${COL_CYAN}STRG + A + D${COL_WHITE}, sonst stürzt der Server ab."
                    sleep 3
                    screen -r ${SCREENAME}
                else
                    echo " "
                    echo "Der Server wird gestartet."
                    echo " "
                    echo " "
                    echo " "
                    run
                fi
            else
                echo " "
                echo "Der Server ist bereits gestartet."
                echo " "
                echo " "
                echo " "
                run
            fi
            ;;
        "stop")
            if [ -e BungeeCord.jar.info ]; then
                screen -S ${SCREENAME} -X stuff "say Der Server wird gestoppt!\n"
                screen -S ${SCREENAME} -X stuff "end\n"
                echo " "
                echo "Der Server wurde gestoppt."
                echo " "
                echo " "
                echo " "
                run
            else
                screen -S ${SCREENAME} -X stuff "say Der Server wird gestoppt!\n"
                screen -S ${SCREENAME} -X stuff "save-all\n"
                sleep 3
                screen -S ${SCREENAME} -X stuff "stop\n"
                echo " "
                echo "Der Server wurde gestoppt."
                echo " "
                echo " "
                echo " "
                run
            fi
            ;;
        "restart")
            if [ -e BungeeCord.jar.info ]; then
                screen -S ${SCREENAME} -X stuff "say Der Server wird neugestartet!\n"
                screen -S ${SCREENAME} -X stuff "end\n"
            else
                screen -S ${SCREENAME} -X stuff "say Der Server wird neugestartet!\n"
                screen -S ${SCREENAME} -X stuff "save-all\n"
                sleep 3
                screen -S ${SCREENAME} -X stuff "stop\n"
            fi

            echo " "
            echo "${COL_CYAN}[INFO] ${COL_GRAY}Server wurde gestoppt."
            

            i=1
            while [ "$i" -le 10 ]; do
                echo "${COL_CYAN}[INFO] ${COL_GRAY}Startversuch ${i}"
                if ! screen -list | grep -q ${SCREENAME} ; then
                    screen -d -m -S ${SCREENAME} java -Xmx${MAX_RAM} -Xms${MIN_RAM} -XX:+UseG1GC -jar server.jar nogui
                    echo "${COL_WHITE}Der Server wird neugestartet."
                    echo " "
                    echo " "
                    echo " "
                    break
                fi
                sleep 5
                i=$(( i + 1 ))
            done
            run
            ;;
        "view")
            echo " "
            echo "Du wirst in 3 Sekunden in die Konsole weitergeleitet..."
            echo "${COL_RED}WICHTIG: ${COL_WHITE}Verlasse die Konsole mit ${COL_CYAN}STRG + A + D${COL_WHITE}, sonst stürzt der Server ab."
            sleep 3
            screen -r ${SCREENAME}
            ;;
        "kill")
            screen -X -S ${SCREENAME} kill
            echo " "
            echo "Der Screen wurde gekillt"
            echo " "
            echo " "
            echo " "
            run
            ;;
        "info")
            echo " "
            echo "Schaue bitte für mehr Informationen auf Github nach."
            echo " "
            echo "Link: ${COL_CYAN}https://github.com/FetzerTony/startupScript-Minecraft-V2/blob/main/README-DE.md"
            echo " "
            echo " "
            echo " "
            run
            ;;
        "update")
            new_version=$(wget -qO- https://raw.githubusercontent.com/FetzerTony/startupScript-Minecraft-V2/main/version.txt)
            if [ "$SCRIPT_VERSION" \< "$new_version" ]; then
                echo " "
                echo "Neue Version verfügbar: ${COL_CYAN}$new_version"
                echo "${COL_WHITE}Aktuelle Version: ${COL_CYAN}$SCRIPT_VERSION"
                echo " "
                update() {
                    echo "Möchtest du die neuste Version installieren? (${COL_CYAN}y/n${COL_WHITE})"
                    read answer
                    answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
                    case $answer in
                        "y"|"yes")
                            echo " "
                            echo "Die neuste Version wird heruntergeladen."
                            echo "Das Script muss anschließend neu gestartet werden."
                            echo "${COL_GRAY}"
                            sleep 2

                            latest_release=$(wget -qO- https://api.github.com/repos/FetzerTony/startupScript-Minecraft-V2/releases/latest)
                            download_link=$(echo "$latest_release" | grep browser_download_url | grep start-de.sh | cut -d '"' -f 4)
                            wget "$download_link" -O start.sh

                            echo "${COL_WHITE}"
                            exit 0
                            ;;
                        "n"|"no")
                            echo " "
                            echo "Die neuste Version wird nicht heruntergeladen."
                            echo " "
                            echo " "
                            echo " "
                            ;;
                        *)
                            echo "Ungültige Eingabe!"
                            update
                            ;;
                    esac
                }

                update
            else
                echo " "
                echo "Es ist keine neue Version verfügbar."
                echo " "
                echo " "
                echo " "
                run
            fi
            ;;
        "version")
            echo " "
            echo "Aktuelle Version: $SCRIPT_VERSION"
            echo " "
            echo " "
            echo " "
            run
            ;;
        "exit")
            clear
            exit 0
            ;;
        *)
            echo "Ungültige Eingabe!"
            run
            ;;
    esac
}

#-----------------------------------------------------
# VERSION NICHT ÄNDERN! WIRD VOM SCRIPT BENÖTIGT
SCRIPT_VERSION=1.0
#-----------------------------------------------------




check_update
check_first_run
check_self_test
run