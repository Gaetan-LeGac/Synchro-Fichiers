#!/bin/bash
# Fonction Debug
function Debug {
	echo "$1" >> /home/gaetan/Scripts/Synchro/debug_usb.txt
}
# Fonction Notif
function Notif {
	su - gaetan -c "export DISPLAY=:0; zenity --notification --text='$1' --window-icon='/home/gaetan/.icons/Paper/48x48@2x/emblems/emblem-$2.png'"
}

# Dossiers à synchroniser sur le disque usb
declare -A Async
Async["MUSIQUES"]="/home/gaetan/Musique/*"
Async["PROJETS"]="/home/gaetan/Bureau/DEV/*"
Async["LOGICIELS"]="/home/gaetan/Téléchargements/LOGICIELS/*"
# Nom des clés USB a surveiller
ClesUSB=("MUSIQUES" "DONNEES")

# Mode d'execution
if [ "$1" == "installer" ]; then
	# ===============> INSTALLATEUR <=====================
	# Acces root
	if [[ $EUID -ne 0 ]]; then
		echo "Sudo stp"
		exit 1
	fi
	PrefixeServ="/etc/systemd/system/SyncUSB-"
	# Suppression des anciens fichiers de triggering
	sudo rm "$PrefixeServ"*
	# Installation des services de triggering USB
	for i in "${!ClesUSB[@]}"; do
		CleUSB=${ClesUSB[$i]}
		CheminServ="$PrefixeServ$CleUSB.service"
		# Ecriture du fichier
		cat > "$CheminServ" << EOL
[Unit]
Description=Synchronisation USB automatique
Requires=media-gaetan-${CleUSB}.mount
After=media-gaetan-${CleUSB}.mount

[Service]
ExecStart=/home/gaetan/Scripts/Synchro/Sync-USB.sh ${CleUSB}

[Install]
WantedBy=media-gaetan-${CleUSB}.mount
EOL
		# Définition des droits
		sudo chown root:root "$CheminServ"
		# Activation du service
		sudo systemctl enable $(basename $CheminServ)
	done
	exit 1
elif [ ! -z ${1+x} ]; then # Verif si paramètre défini
	# ===============> SYNCHRONISATEUR <==================
	nomCle="$1"
	# Verif existance des dossiers speciaux
	Debug "Traitement de la clé $nomCle"
	for Dossier in "${!Async[@]}"
	do
		Debug "verif existance dossier $Dossier"
		# Chemins
		Source=${Async[$Dossier]}
		Destination="/media/gaetan/$nomCle/$Dossier"
		
		if [ "$nomCle" == "$Dossier" ]; then
			Debug "Clé dédiée"
			# ========> CLE DEDIÉE <==========
			Notif "Synchronisation de la clé $nomCle" "dropbox-syncing"
			# Synchronisation
			sudo rsync -vrtzluLgo --delete $Source $Chemin
		elif [ -d $Destination ]; then
			Debug "Dossier dédiée"
			# ========> DOSSIER DEDIÉ <==========
			Notif "Synchronisation de $Dossier sur la clé $nomCle" "dropbox-syncing"
			# Synchronisation
			sudo rsync -vrtzluLgo --delete $Source $Destination
			# v : Verbose
			# r : Recursif
			# t : Date & heure
			# z : Compression durant le transfert
			# l : Copie des liens & liens symboliques
			# u : Ignore les fichiers déjà existants & à jour
			# L : Fichiers référencés par lien système
			# g : Conservation groupe
			# o : Conservation propriétaire
		fi
	done
	
	# Fin
	Debug "Fin de la boucle"
	Notif "Synchronisation de la clé USB terminée." "default"
	
	# Calcul de l'espace libre sur le disque
	#libre=$(df -k --total --output=avail "$CheminSnaps" | sed -n 2p)
	#echo "libre: $libre"
else
	Debug "Nom de la clé indéfini"
fi
