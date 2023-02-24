# Install / Startup Script for Minecraft Server
#### Including Spigot, Paper, Vanilla, CraftBukkit, Fabric and Bungeecord

### :heavy_exclamation_mark: German Version
[Klicke hier](https://github.com/FetzerTony/startupScript-Minecraft-V2/blob/main/README-DE.md), um zur deutschen Version zu gelangen!

### :information_source: INFORMATION
The script can be used to install and control servers.

### :no_entry: IMPORTANT
- for Linux only!

## :wrench: Required tools
- **screen** (_Can be installed by the script_)
- **jq** (only for Paper) (_Can be installed by the script_)
- [**Java**](https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-on-ubuntu-18-04-de) (correct java version for server version)

## :hammer_and_wrench: Installation & Configuration
1. Download the **start.sh** file from the latest release.
1. Put the **start.sh** file in the desired folder.. (Rename it if you want to)
2. Open the file and change **"DIRECTORY"** to the directory, where you want the server. (Default: _own folder_)
3. Change **"SCREENNAME"** to the screen name you want.
4. Set **"MAX_RAM"** to the maximum amount of RAM you will give the server and **"MIN_RAM"** to the minimum amount.
5. Type `chmod 777 start.sh` in the server console.
6. That's it, for more settings you can also change the other parameters.

### :page_facing_up: other Variables

- **"START_CONSOLE=true"** = opens the console, when the server starts.
- **"AUTO_UPDATE=true"** = automatically checks for updates

## :star: starting command
1. Go to the folder where the startup file is located. ```cd /<directory>```
2. Start the script with ```./start.sh```
