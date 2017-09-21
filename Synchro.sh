#!/bin/bash
# Chemins
utilisateur="gaetan"
dPerso="/home/$utilisateur"

dBase="$dPerso/Scripts/Synchro"
DossierUnison="$dPerso/.unison"

# Importations
source $dBase/Fonctions/Message.sh
source $dBase/Fonctions/IpServeur.sh

# Vérifie si le serveur est occupé
function ServeurOccupe { 
	idProc=$(ssh root@$IP -p $Port 'pidof -x "unison"')
	if [[ $idProc ]]; then
		nomProc=$(ssh root@$IP -p $Port "cat /proc/$idProc/cmdline")
		#if [[ $nomProc != "unison-server" ]]; then
			echo "true"
		#fi 
	fi 
}

# Liste des profils unison
Profils=("Donnees" "Projets" "Web" "Configs")

# Vérif si la synchro n'est pas déjà lancée
if ( ! pidof -x "unison" > /dev/null ); then
	# Mode d'execution
	if [ "$1" == "installer" ]; then
		# =============> INSTALL <==============
		# Verif existance dossier unison
		if [ ! -d $DossierUnison ]; then
			echo "Création du dossier unison"
			mkdir $DossierUnison
		fi
		# Installation des fichiers de profil
		for Profil in ${Profils[@]}; do
			echo "Installation du profil $Profil"
			echo "test de $cheminProfil"
			if [ -f "$cheminProfil" ]; then
				echo "maj de $cheminProfil"
			fi
			cp "./Profils_Unison/$Profil.prf" "$cheminProfil"
		done
		# Config de la tache cron
		echo "Ajouter cette ligne dans la config cron:"
		echo "30 * * * * $dBase/Synchro.sh"
		read a
		crontab -u $utilisateur -e
		# Installation au démarrage
		echo "Installation au démarrage"
		scriptBoot="/etc/init.d/Synchro.sh"
		sudo sh -c "cat > $scriptBoot << EOL
#!/bin/bash
su - $utilisateur '/home/$utilisateur/Scripts/Synchro/Synchro.sh'
EOL"
		sudo chmod 755 $scriptBoot
		# Fin
		echo "Installation terminée."
	else
		# ==============> SYNCHRO <============
		# Debug
		#exec >$dBase/synchro.log 2>&1
		# Récupèration de l'IP du serveur (local ou internet) & verif connexion
		RecupInfosServeur
		if [[ $IP != false ]]; then
			# Vérification si une synchro est déjà en cours sur le serveur
			while [[ $(ServeurOccupe) ]]; do
				Notif "Synchronisation reportée dans 30 secondes.\nLe serveur est occupé." "dropbox-unsyncable"
				sleep 30
			done
			# Notif
			Notif "Synchronisation du PC en cours\nIP serveur: $IP:$Port" "dropbox-syncing"
			# Synchronisation de chaque dossier
			for Profil in ${Profils[@]}; do
				printf "Synchronisation de $Profil \n"
				# Si on est pas en local
				if [ "$IP" != "$IPLocal" ]; then
					# Création / màj & utilisation du profil internet
					ProfilInternet="$Profil-Internet"
					sed "s/$IPLocal:$PortLocal/$IP:$Port/g" "$DossierUnison/$Profil.prf" > "$DossierUnison/$ProfilInternet.prf"
					Profil=$ProfilInternet
				fi
				# Lancement de la commande
				eval "unison $Profil"
			done
			# Fin
			Notif "Synchronisation du PC terminée." "default"
		else
			Notif "Synchronisation annulée\nImpossible d'atteindre le serveur" "dropbox-unsyncable"
		fi
	fi
else
	Notif "Une synchronisation est déjà en cours sur ce PC." "dropbox-unsyncable"
	echo "La synchro est déjà en train de tourner pour ce PC."
fi
