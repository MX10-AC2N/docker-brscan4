#!/usr/bin/env bash
set -e

echo "=== update-drivers.sh - VERSION FINALE ==="

UPDATED=false

for deb in drivers/*.deb; do
    [ ! -f "$deb" ] && continue

    echo "→ $(basename "$deb")"

    pkg=\( (dpkg-deb --show --showformat=' \){Package}' "$deb" 2>/dev/null || basename "$deb" | cut -d- -f1)
    ver=\( (dpkg-deb --show --showformat=' \){Version}' "$deb" 2>/dev/null || echo "unknown")

    echo "  Version actuelle : $ver"

    case "$pkg" in
        brscan4)
            new_ver="0.4.11-1"
            url="https://download.brother.com/welcome/dlf105200/brscan4-${new_ver}.amd64.deb"
            ;;
        brscan-skey)
            new_ver="0.3.4-0"
            url="https://download.brother.com/welcome/dlf006652/brscan-skey-${new_ver}.amd64.deb"
            ;;
        brother-udev-rule-type1)
            echo "  (déjà à jour)"
            continue
            ;;
        *)
            echo "  Driver non géré"
            continue
            ;;
    esac

    if [ "$new_ver" != "$ver" ]; then
        echo "  → Mise à jour disponible : $ver → $new_ver"

        # Suppression propre de l'ancien fichier
        cd drivers
        rm -f "$(basename "$deb")"
        cd ..

        # Téléchargement du nouveau
        cd drivers
        curl -fSL -O "$url"
        cd ..

        UPDATED=true
        echo "  ✅ Mis à jour : $(basename "$url")"
    else
        echo "  ✅ Déjà à jour"
    fi
done

echo ""
if [ "$UPDATED" = true ]; then
    echo "🎉 AU MOINS UNE MISE À JOUR A ÉTÉ EFFECTUÉE"
else
    echo "✅ Tous les drivers sont déjà à jour"
fi