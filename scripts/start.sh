#!/bin/bash
set -e

echo "════════════════════════════════════════"
echo "  ⚙️  Initialisation brscan-skey"
echo "════════════════════════════════════════"

# --- Permissions sur le dossier de scans ---
echo "  📁 Ajustement des permissions sur /scans (PUID=${PUID:-1000} PGID=${PGID:-1000})..."
chown -R "${PUID:-1000}:${PGID:-1000}" /scans

# --- Enregistrement du scanner (sécurisé) ---
echo "  🔧 Configuration brsaneconfig4..."
/usr/bin/brsaneconfig4 -a \
    name="${SCANNER_NAME:-BrotherScanner}" \
    model="${SCANNER_MODEL}" \
    ip="${SCANNER_IP_ADDRESS}"

echo "  ✅ Scanner configuré."
echo "════════════════════════════════════════"
echo "  🟢 Lancement de brscan-skey (daemon)..."
echo "════════════════════════════════════════"

# Lance brscan-skey en foreground (maintient le container actif)
exec /usr/bin/brscan-skey -f
