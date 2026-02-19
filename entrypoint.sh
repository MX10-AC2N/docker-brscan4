#!/bin/bash
set -e

echo "════════════════════════════════════════"
echo "  🚀 Démarrage docker-brscan4"
echo "════════════════════════════════════════"

# --- Validation des variables obligatoires ---
if [ -z "${SCANNER_MODEL}" ]; then
    echo "  ❌ ERREUR : SCANNER_MODEL est obligatoire !"
    echo "     Exemple : -e SCANNER_MODEL=\"MFC-L2700DW\""
    echo "     Vérifiez le nom EXACT sur https://support.brother.com"
    exit 1
fi

if [ -z "${SCANNER_IP_ADDRESS}" ]; then
    echo "  ❌ ERREUR : SCANNER_IP_ADDRESS est obligatoire !"
    echo "     Exemple : -e SCANNER_IP_ADDRESS=\"192.168.1.200\""
    exit 1
fi

# --- Résumé de la configuration ---
echo "  📠 Modèle      : ${SCANNER_MODEL}"
echo "  🌐 IP          : ${SCANNER_IP_ADDRESS}"
echo "  🏷️  Nom logique : ${SCANNER_NAME:-BrotherScanner}"
echo "  🕐 Timezone    : ${TZ:-Europe/Paris}"
echo "════════════════════════════════════════"

# --- Configuration du backend SANE ---
echo "  🔧 Enregistrement du scanner via brsaneconfig4..."
brsaneconfig4 -a \
    name="${SCANNER_NAME:-BrotherScanner}" \
    model="${SCANNER_MODEL}" \
    ip="${SCANNER_IP_ADDRESS}"

echo "  ✅ Scanner enregistré."

# --- Liste des scanners détectés ---
echo "════════════════════════════════════════"
echo "  🔍 Scanners détectés par SANE :"
scanimage -L || echo "  ⚠️  Aucun scanner détecté (normal si réseau pas encore prêt)"
echo "════════════════════════════════════════"

# --- Lancement du daemon brscan-skey ---
exec /opt/brother/docker_skey/scripts/start.sh
