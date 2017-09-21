#!/bin/bash
#IPLocal="192.168.1.83"
IPLocal="10.42.0.1"
PortLocal="22"
PortDistant="60"

# ===========> FONCTIONS <===========
# Teste la conneixon sur une IP pour un port donné
# Pour déterminer le type de réseau sur lequel on se trouve
function verifConnexion {
	 echo $(nmap $1 -PN -p $2 | grep open)
}

function getIpMaison {
	IP=$(curl http://www.gaetan-legac.fr/Maison/ip.txt 2>/dev/null)
	echo $IP
}

function RecupInfosServeur {
	# Vérif si réseau local
	if [[ $(verifConnexion $IPLocal $PortLocal) ]]; then
		# Réseau local
		IP=$IPLocal
		Port=$PortLocal
	elif [[ $(verifConnexion $IPLocal $PortLocal) ]]; then
		# Réseau autre, connexion via internet
		IP=$(getIpMaison)
		Port=$PortDistant
	else
		IP=false
	fi
}

# ==========> TESTS <==========
#RecupInfosServeur && echo "$IP : $Port"
