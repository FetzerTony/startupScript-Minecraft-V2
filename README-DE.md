# Installations- / Startskript für Minecraft Server
#### Einschließlich Spigot, Papier, Vanilla, CraftBukkit, Fabric und Bungeecord

### :heavy_exclamation_mark: English Version
[Click here](https://github.com/FetzerTony/startupScript-Minecraft-V2/) to go to the English version!

### :information_source: INFORMATION
Das Skript kann zur Installation und Steuerung von Servern verwendet werden.

### :no_entry: WICHTIG
- nur für Linux!

## :wrench: benötigte Tools
- **screen** (_Kann über das Script installiert werden_)
- **jq** (only for Paper) (_Kann über das Script installiert werden_)
- [**Java**](https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-on-ubuntu-18-04-de) (passende Java-Version für Server-Version)

## :hammer_and_wrench: Installation & Konfiguration
1. Lade die Datei **start-de.sh** aus dem neusten Release herunter.
3. Lege die Datei **start-de.sh** in den gewünschten Ordner und ändere den Namen um zu **start.sh**.
4. Öffne die Datei und ändere **"DIRECTORY"** in das Verzeichnis, in dem du den Server haben möchtest. (Standard: _eigener Ordner_)
5. Ändere **"SCREENNAME"** in den gewünschten Screen Namen.
6. Stellee **"MAX_RAM"** auf die maximale Menge an RAM ein, die du dem Server geben möchtest, und **"MIN_RAM"** auf die minimale Menge.
7. Gebe `chmod 777 start.sh` in die Serverkonsole ein.
8. Das war's, für weitere Einstellungen kannst du auch die anderen Variablen ändern.

### :page_facing_up: andere Variablen

- **"START_CONSOLE=true"** = Öffnet die Konsole, wenn der Server gestartet wird
- **"AUTO_UPDATE=true"** = Sucht automatisch nach Updates

## :star: Start Commands
1. Wechsel in den Ordner, in dem sich die Startdatei befindet. ```cd /<directory>```
2. Starte das Script mit ```./start.sh```
