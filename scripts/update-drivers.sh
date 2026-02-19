#!/usr/bin/env bash
set -e

echo "=== update-drivers.sh - VERSION FINALE PROPRE ==="

UPDATED=false

# brscan4
if ls drivers/brscan4-*.deb 1> /dev/null 2>&1; then
  echo "→ brscan4 détecté → mise à jour vers 0.4.11-1"
  cd drivers
  rm -f brscan4-*.deb
  curl -fSL -O "https://download.brother.com/welcome/dlf105200/brscan4-0.4.11-1.amd64.deb"
  cd ..
  UPDATED=true
  echo "  ✅ brscan4 mis à jour"
fi

# brscan-skey
if ls drivers/brscan-skey-*.deb 1> /dev/null 2>&1; then
  echo "→ brscan-skey détecté → mise à jour vers 0.3.4-0"
  cd drivers
  rm -f brscan-skey-*.deb
  curl -fSL -O "https://download.brother.com/welcome/dlf006652/brscan-skey-0.3.4-0.amd64.deb"
  cd ..
  UPDATED=true
  echo "  ✅ brscan-skey mis à jour"
fi

# brother-udev-rule-type1 (déjà à jour)
if ls drivers/brother-udev-rule-type1-*.deb 1> /dev/null 2>&1; then
  echo "→ brother-udev-rule-type1 (déjà à jour)"
fi

echo ""
if [ "$UPDATED" = true ]; then
  echo "🎉 AU MOINS UNE MISE À JOUR A ÉTÉ EFFECTUÉE"
else
  echo "✅ Tous les drivers sont déjà à jour"
fi