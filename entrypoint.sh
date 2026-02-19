#!/bin/bash
set -e

# Validation des variables obligatoires
if [ -z "$SCANNER_MODEL" ]; then
    echo "ERREUR : SCANNER_MODEL est obligatoire !"
    echo "Exemple : -e SCANNER_MODEL=\"MFC-L2700DW\""
    echo "Vérifiez le nom EXACT sur https://support.brother.com → votre modèle → Linux → Scanner Driver"
    echo "Modèles courants compatibles brscan4 : DCP-L2520DW, DCP-L2540DW, MFC-L2700DW, MFC-L2710DW, MFC-L2740DW, MFC-L2750DW, MFC-J5620DW, etc."
    exit 1
fi

if [ -z "$SCANNER_IP_ADDRESS" ]; then
    echo "ERREUR : SCANNER_IP_ADDRESS est obligatoire pour scanner réseau."
    echo "Exemple : -e SCANNER_IP_ADDRESS=\"192.168.1.200\""
    exit 1
fi

# Configuration du backend SANE (exécuté au démarrage)
echo "Configuration du scanner : name=\( {SCANNER_NAME:-BrotherScanner} model= \){SCANNER_MODEL} ip=${SCANNER_IP_ADDRESS}"
brsaneconfig4 -a name="\( {SCANNER_NAME:-BrotherScanner}" model=" \){SCANNER_MODEL}" ip="${SCANNER_IP_ADDRESS}"

# Debug : liste les scanners détectés
scanimage -L

# Lancement de ton script principal (brscan-skey, daemon, etc.)
exec /opt/brother/docker_skey/scripts/start.sh