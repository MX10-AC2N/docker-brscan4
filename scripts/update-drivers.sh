#!/usr/bin/env bash
set -e

echo "=== update-drivers.sh - VERSION FINALE === "

UPDATED=false

echo "Fichiers trouvés dans drivers/ :"
ls -1 drivers/*.deb 2>/dev/null || echo "aucun"

# ==================== brscan4 ====================
if ls drivers/brscan4-*.deb 1>/dev/null 2>&1; then
    echo "→ brscan4 détecté"
    if curl -s -o /dev/null -w "%{http_code}" "https://download.brother.com/welcome/dlf105200/brscan4-0.4.11-1.amd64.deb" | grep -q "200"; then
        echo "  Mise à jour vers 0.4.11-1"
        cd drivers
        rm -f brscan4-*.deb 2>/dev/null || true
        curl -fSL -O "https://download.brother.com/welcome/dlf105200/brscan4-0.4.11-1.amd64.deb"
        cd ..
        UPDATED=true
    else
        echo "  Pas de mise à jour disponible pour brscan4"
    fi
fi

# ==================== brscan-skey ====================
if ls drivers/brscan-skey-*.deb 1>/dev/null 2>&1; then
    echo "→ brscan-skey détecté"
    if curl -s -o /dev/null -w "%{http_code}" "https://download.brother.com/welcome/dlf006652/brscan-skey-0.3.4-0.amd64.deb" | grep -q "200"; then
        echo "  Mise à jour vers 0.3.4-0"
        cd drivers
        rm -f brscan-skey-*.deb 2>/dev/null || true
        curl -fSL -O "https://download.brother.com/welcome/dlf006652/brscan-skey-0.3.4-0.amd64.deb"
        cd ..
        UPDATED=true
    else
        echo "  Pas de mise à jour disponible pour brscan-skey"
    fi
fi

# ==================== brother-udev-rule-type1 ====================
if ls drivers/brother-udev-rule-type1-*.deb 1>/dev/null 2>&1; then
    echo "→ brother-udev-rule-type1 détecté (déjà à jour)"
fi

echo ""
if [ "$UPDATED" = true ]; then
    echo "🎉 AU MOINS UNE MISE À JOUR A ÉTÉ EFFECTUÉE"
else
    echo "✅ Tous les drivers sont déjà à jour"
fi