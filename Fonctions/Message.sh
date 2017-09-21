#!/bin/bash

# Fonction Debug
function Debug {
	heure=$(date +%H:%M)
	echo "$heure $1" >> /home/gaetan/Scripts/Synchro/debug.txt
}

# Fix : Détermine le DBUS de l'utilisateur courant
DBUS=$(pgrep -ou $(whoami) cinnamon)
DBUS="$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$DBUS/environ | sed 's/DBUS_SESSION_BUS_ADDRESS=//')"

# Fonction de notif
function Notif {
	DBUS_SESSION_BUS_ADDRESS="$DBUS" zenity --notification --text="$1" --window-icon="/home/gaetan/.icons/Paper/48x48@2x/emblems/emblem-$2.png" --display=:0.0
}

