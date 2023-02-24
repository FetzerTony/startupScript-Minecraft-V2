#!/bin/sh

# Customizable variables
DIRECTORY="$PWD"
SCREENAME='example'
MIN_RAM="1G"
MAX_RAM="2G"
START_CONSOLE=true
AUTO_UPDATE=true

# colors
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
            echo "New version available: ${COL_CYAN}$new_version"
            echo "${COL_WHITE}Current version: ${COL_CYAN}$SCRIPT_VERSION"
            echo " "
            update() {
                echo "Do you want to install the latest version? (${COL_CYAN}y/n${COL_WHITE})"
                read answer
                answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
                case $answer in
                    "y"|"yes")
                        echo " "
                        echo "The latest version will be downloaded."
                        echo "The script must then be restarted."
                        echo "${COL_GRAY}"
                        sleep 2

                        latest_release=$(wget -qO- https://api.github.com/repos/FetzerTony/startupScript-Minecraft-V2/releases/latest)
                        download_link=$(echo "$latest_release" | grep browser_download_url | grep start.sh | cut -d '"' -f 4)
                        wget "$download_link" -O start.sh

                        echo "${COL_WHITE}"
                        exit 0
                        ;;
                    "n"|"no")
                        echo " "
                        echo "The latest version will not be downloaded."
                        ;;
                    *)
                        echo "Unknown command!"
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
        echo "${COL_CYAN}[INFO] ${COL_GRAY}The script was started for the first time and there is no server.jar"
        echo "${COL_WHITE}Welcome to the server configuration. You can cancel at any time with CTRL + C"
        echo " "

        CONFIRMATION=true
        SOFTWARE=
        VERSION=


        config_software() {
            echo "Which software do you want to install? (${COL_CYAN}Spigot|Paper|Vanilla|CraftBukkit|Fabric|Bungeecord${COL_WHITE})"
            read answer
            answer=$(echo $answer | tr '[:upper:]' '[:lower:]')

            case $answer in
                "spigot"|"paper"|"vanilla"|"craftbukkit"|"fabric"|"bungeecord")
                    echo "${COL_CYAN}${answer} ${COL_WHITE}was selected as software."
                    SOFTWARE="${answer}"
                    ;;
                *)
                    echo "Unknown command!"
                    config_software
                    ;;
            esac
        }

        config_software


        if [ "${SOFTWARE}" != "bungeecord" ]
        then
            config_version() {
                echo " "
                echo "Which version do you want to install? (${COL_GRAY}e.g. 1.19.2${COL_WHITE})"
                read answer
                echo "${COL_CYAN}${answer} ${COL_WHITE}was selected as the version."
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
                    echo "Do you accept the Eula? (${COL_CYAN}y/n${COL_WHITE})"
                    read answer
                    answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
                    case $answer in
                        "y"|"yes")
                            echo "The Eula was accepted."
                            EULA=true
                            CONFIRMATION=true
                            ;;
                        "n"|"no")
                            echo "The Eula was not accepted and the process was aborted."
                            exit 1
                            ;;
                        *)
                            echo "Unknown command!"
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
                echo "Screen is not installed. Do you want to install screen? (${COL_CYAN}y/n${COL_WHITE})"
                read answer
                answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
                    case $answer in
                    "y"|"yes")
                        echo "Screen will be installed."
                        SCREEN=true
                        CONFIRMATION=true
                        ;;
                    "n"|"no")
                        echo "Screen will not be installed and the process will be aborted."
                        exit 1
                        ;;
                    *)
                        echo "Unknown command!"
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
            echo "Do you confirm your configuration? (${COL_CYAN}y/n${COL_WHITE})"
            read answer
            answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
            case $answer in
                "y"|"yes")
                    echo "The server is now being set up, this may take a moment. You will be redirected to the console..."

                    if ${EULA}; then
                        echo "eula=true" > eula.txt
                        echo "${COL_CYAN}[INFO] ${COL_GRAY}Eula was set to true"
                    fi

                    if ${SCREEN}; then
                        sudo apt-get update
                        sudo apt-get install screen
                        echo "${COL_CYAN}[INFO] ${COL_GRAY}Screen has been installed"
                    fi

                    case $SOFTWARE in
                        "bungeecord")
                            echo "${COL_CYAN}[INFO] ${COL_GRAY}Bungeecord will be installed"

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
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar has been installed. (url_1)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar not correct. (url_1)"
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
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar has been installed. (url_2)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar not correct. (url_2)"
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
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar has been installed. (url_3)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar not correct. (url_3)"
                                        rm "server.jar"
                                        echo " "
                                        echo "${COL_RED}[WARNING] ${COL_WHITE}Spigot ${VERSION} could not be found. If the version is available, please proceed as follows"
                                        echo "  ${COL_CYAN}1. ${COL_WHITE}Download the version."
                                        echo "  ${COL_CYAN}2. ${COL_WHITE}Put it in the server folder."
                                        echo "  ${COL_CYAN}3. ${COL_WHITE}Rename the file to ${COL_CYAN}server.jar ${COL_WHITE}."
                                        echo "  ${COL_CYAN}Optional: ${COL_WHITE}Create an .info file with the name of the file. (z.B. spigot-1.19.2.jar)"
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
                                        echo "jq is not installed. Do you want to install jq? (${COL_CYAN}y/n${COL_WHITE})"
                                        read answer
                                        answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
                                            case $answer in
                                            "y"|"yes")
                                                echo "jq will be installed."
                                                echo "${COL_GRAY}"
                                                sudo apt-get update
                                                sudo apt-get install jq
                                                echo "${COL_CYAN}[INFO] ${COL_GRAY}jq has been installed."
                                                ;;
                                            "n"|"no")
                                                echo "jq will not be installed and the process will be aborted."
                                                exit 1
                                                ;;
                                            *)
                                                echo "Unknown command!"
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
                                    echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar has been installed."
                                    touch "${filename}.info"
                                else
                                    echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar could not be installed."
                                    rm "server.jar"
                                    echo " "
                                    echo "${COL_RED}[WARNING] ${COL_WHITE}Paper ${VERSION} could not be found. If the version is available, please proceed as follows"
                                    echo "  ${COL_CYAN}1. ${COL_WHITE}Download the version."
                                    echo "  ${COL_CYAN}2. ${COL_WHITE}Put it in the server folder."
                                    echo "  ${COL_CYAN}3. ${COL_WHITE}Rename the file to ${COL_CYAN}server.jar ${COL_WHITE}."
                                    echo "  ${COL_CYAN}Optional: ${COL_WHITE}Create an .info file with the name of the file. (z.B. paper-1.19.2-396.jar)"
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
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar has been installed. (url_1)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar not correct. (url_1)"
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
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar has been installed. (url_2)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar not correct. (url_2)"
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
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar has been installed. (url_3)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar not correct. (url_3)"
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
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar has been installed. (url_4)"
                                        touch "${filename}.info"
                                    else
                                        echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar not correct. (url_4)"
                                        rm "server.jar"
                                        echo " "
                                        echo "${COL_RED}[WARNING] ${COL_WHITE}CraftBukkit ${VERSION} could not be found. If the version is available, please proceed as follows"
                                        echo "  ${COL_CYAN}1. ${COL_WHITE}Download the version."
                                        echo "  ${COL_CYAN}2. ${COL_WHITE}Put it in the server folder."
                                        echo "  ${COL_CYAN}3. ${COL_WHITE}Rename the file to ${COL_CYAN}server.jar ${COL_WHITE}."
                                        echo "  ${COL_CYAN}Optional: ${COL_WHITE}Create an .info file with the name of the file. (z.B. craftbukkit-1.19.2.jar)"
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
                                    echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar has been installed."
                                    touch "fabric-${VERSION}.jar.info"
                                else
                                    echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar could not be installed"
                                    rm "server.jar"
                                    echo " "
                                    echo "${COL_RED}[WARNING] ${COL_WHITE}Fabric ${VERSION} could not be found. If the version is available, please proceed as follows"
                                    echo "  ${COL_CYAN}1. ${COL_WHITE}Download the version."
                                    echo "  ${COL_CYAN}2. ${COL_WHITE}Put it in the server folder."
                                    echo "  ${COL_CYAN}3. ${COL_WHITE}Rename the file to ${COL_CYAN}server.jar ${COL_WHITE}."
                                    echo "  ${COL_CYAN}Optional: ${COL_WHITE}Create an .info file with the name of the file. (z.B. fabric-1.19.3.jar)"
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
                                echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar has been installed."
                                rm downloads.txt
                            else
                                echo "${COL_CYAN}[INFO] ${COL_GRAY}server.jar could not be installed"
                                echo " "
                                echo "${COL_RED}[WARNING] ${COL_WHITE}Vanilla ${VERSION} could not be found. If the version is available, please proceed as follows"
                                echo "  ${COL_CYAN}1. ${COL_WHITE}Download the version."
                                echo "  ${COL_CYAN}2. ${COL_WHITE}Put it in the server folder."
                                echo "  ${COL_CYAN}3. ${COL_WHITE}Rename the file to ${COL_CYAN}server.jar ${COL_WHITE}."
                                echo "  ${COL_CYAN}Optional: ${COL_WHITE}Create an .info file with the name of the file. (z.B. Vanilla-1.19.3.jar)"
                                rm downloads.txt
                                exit 1
                            fi
                            ;;
                    esac

                    echo "${COL_WHITE}"
                    ;;
                "n"|"no")
                    echo "The configuration was aborted."
                    exit 1
                    ;;
                *)
                    echo "Unknown command!"
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
                echo "Screen is not installed. Do you want to install screen? (${COL_CYAN}y/n${COL_WHITE})"
                read answer
                answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
                    case $answer in
                    "y"|"yes")
                        echo "Screen will be installed."
                        echo "${COL_GRAY}"
                        sudo apt-get install screen
                        echo "${COL_WHITE}"
                        ;;
                    "n"|"no")
                        echo "Screen will not be installed and the process will be aborted."
                        exit 1
                        ;;
                    *)
                        echo "Unknown command!"
                        config_screen
                        ;;
                esac
        }

        config_screen
    fi
}

run() {
    echo " "
    echo "${COL_WHITE}What action do you want to perform: (${COL_CYAN}start, stop, restart, view, kill, info, update, version, exit${COL_WHITE})"
    read arg
    arg=$(echo $arg | tr '[:upper:]' '[:lower:]')
    case $arg in
        "start")
            if ! screen -list | grep -q ${SCREENAME} ; then
                screen -d -m -S ${SCREENAME} java -Xmx${MAX_RAM} -Xms${MIN_RAM} -XX:+UseG1GC -jar server.jar nogui
                if $START_CONSOLE; then
                    echo " "
                    echo "The server will be started. You will be redirected to the console in 3 seconds..."
                    echo "${COL_RED}IMPORTANT: ${COL_WHITE}Exit the console with ${COL_CYAN}CTRL + A + D${COL_WHITE} or the server will crash."
                    sleep 3
                    screen -r ${SCREENAME}
                else
                    echo " "
                    echo "The server will be started."
                    echo " "
                    echo " "
                    echo " "
                    run
                fi
            else
                echo " "
                echo "The server is already started."
                echo " "
                echo " "
                echo " "
                run
            fi
            ;;
        "stop")
            if [ -e BungeeCord.jar.info ]; then
                screen -S ${SCREENAME} -X stuff "say The server will be stopped!\n"
                screen -S ${SCREENAME} -X stuff "end\n"
                echo " "
                echo "The server has been stopped."
                echo " "
                echo " "
                echo " "
                run
            else
                screen -S ${SCREENAME} -X stuff "say The server will be stopped!\n"
                screen -S ${SCREENAME} -X stuff "save-all\n"
                sleep 3
                screen -S ${SCREENAME} -X stuff "stop\n"
                echo " "
                echo "The server has been stopped."
                echo " "
                echo " "
                echo " "
                run
            fi
            ;;
        "restart")
            if [ -e BungeeCord.jar.info ]; then
                screen -S ${SCREENAME} -X stuff "say The server will be restarted!\n"
                screen -S ${SCREENAME} -X stuff "end\n"
            else
                screen -S ${SCREENAME} -X stuff "say The server will be restarted!\n"
                screen -S ${SCREENAME} -X stuff "save-all\n"
                sleep 3
                screen -S ${SCREENAME} -X stuff "stop\n"
            fi

            echo " "
            echo "${COL_CYAN}[INFO] ${COL_GRAY}Server has been stopped."
            

            i=1
            while [ "$i" -le 10 ]; do
                echo "${COL_CYAN}[INFO] ${COL_GRAY}start attempt ${i}"
                if ! screen -list | grep -q ${SCREENAME} ; then
                    screen -d -m -S ${SCREENAME} java -Xmx${MAX_RAM} -Xms${MIN_RAM} -XX:+UseG1GC -jar server.jar nogui
                    echo "${COL_WHITE}The server is restarted."
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
            echo "You will be redirected to the console in 3 seconds..."
            echo "${COL_RED}IMPORTANT: ${COL_WHITE}Exit the console with ${COL_CYAN}CTRL + A + D${COL_WHITE} or the server will crash."
            sleep 3
            screen -r ${SCREENAME}
            ;;
        "kill")
            screen -X -S ${SCREENAME} kill
            echo " "
            echo "The screen has been killed"
            echo " "
            echo " "
            echo " "
            run
            ;;
        "info")
            echo " "
            echo "Please check Github for more information."
            echo " "
            echo "Link: ${COL_CYAN}https://github.com/FetzerTony/startupScript-Minecraft-V2/blob/main/README.md"
            echo " "
            echo " "
            echo " "
            run
            ;;
        "update")
            new_version=$(wget -qO- https://raw.githubusercontent.com/FetzerTony/startupScript-Minecraft-V2/main/version.txt)
            if [ "$SCRIPT_VERSION" \< "$new_version" ]; then
                echo " "
                echo "New version available: ${COL_CYAN}$new_version"
                echo "${COL_WHITE}Current version: ${COL_CYAN}$SCRIPT_VERSION"
                echo " "
                update() {
                    echo "Do you want to install the latest version? (${COL_CYAN}y/n${COL_WHITE})"
                    read answer
                    answer=$(echo $answer | tr '[:upper:]' '[:lower:]')
                    case $answer in
                        "y"|"yes")
                            echo " "
                            echo "The latest version will be downloaded."
                            echo "The script must then be restarted."
                            echo "${COL_GRAY}"
                            sleep 2

                            latest_release=$(wget -qO- https://api.github.com/repos/FetzerTony/startupScript-Minecraft-V2/releases/latest)
                            download_link=$(echo "$latest_release" | grep browser_download_url | grep start.sh | cut -d '"' -f 4)
                            wget "$download_link" -O start.sh

                            echo "${COL_WHITE}"
                            exit 0
                            ;;
                        "n"|"no")
                            echo " "
                            echo "The latest version will not be downloaded."
                            echo " "
                            echo " "
                            echo " "
                            ;;
                        *)
                            echo "Unknown command!"
                            update
                            ;;
                    esac
                }

                update
            else
                echo " "
                echo "There is no new version available."
                echo " "
                echo " "
                echo " "
                run
            fi
            ;;
        "version")
            echo " "
            echo "Current version: $SCRIPT_VERSION"
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
            echo "Unknown command!"
            run
            ;;
    esac
}

#-----------------------------------------------------
# DONT CHANGE THE VERSION! ITS FOR THE SCRIPT!
SCRIPT_VERSION=1.0
#-----------------------------------------------------




check_update
check_first_run
check_self_test
run