#!/bin/bash

IpLocal="10.42.0.1:22"
IpInternet="78.116.118.169:60"

fInternet=/home/gaetan/Scripts/Synchro/Profils_Unison/Donnees_ViaInternet.prf

sed "s/$IpLocal/$IpInternet/g" ./Donnees.prf > ./Donnees_ViaInternet.prf
