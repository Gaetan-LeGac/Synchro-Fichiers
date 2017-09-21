#!/bin/bash

CheminSnaps="/home/DISQUE/USB/Snapshots"

# Calcul de l'espace libre sur le disque de snapshots
libre=$(df -k --total --output=avail "$CheminSnaps" | sed -n 2p)

echo "libre: $libre"
