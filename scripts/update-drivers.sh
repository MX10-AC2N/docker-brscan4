#!/usr/bin/env bash
set -euo pipefail

echo "=== Mise à jour des drivers Brother ==="

UPDATED=false

for deb in drivers/*.deb; do
    [ ! -f "$deb" ] && continue

    echo "→ Traitement : $(basename "$deb")"

    pkg=\( (dpkg-deb --show --showformat=' \){Package}' "$deb" 2>/dev/null || basename "$deb" | cut -d- -f1)
    ver=\( (dpkg-deb --show --showformat=' \){Version}' "$deb" 2>/dev/null || echo "unknown")

    echo "  Version actuelle : $ver"

    if [ "$pkg" = "brscan4" ]; then
        new_ver="0.4.11-1"
        url="https://download.brother.com/welcome/dlf105200/brscan4-${new_ver}.amd64.deb"
    elif [ "$pkg" = "brscan-skey" ]; then
        new_ver="0.3.4-0"
        url="https://download.brother.com/welcome/dlf006652/brscan-skey-${new_ver}.amd64.deb"
    elif [ "$pkg" = "brother-udev-rule-type1" ]; then
        new_ver="1.0.2-0"
        url="https://download.brother.com/welcome/dlf006893/brother-udev-rule-type1-${new_ver}.all.deb"
    else
        echo "  Driver non géré"
        continue
    fi

    if [ "$new_ver" != "$ver" ]; then
        echo "  → Mise à jour disponible : $ver → $new_ver"
        if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200"; then
            echo "  → Téléchargement..."
            cd drivers
            rm -f "$(basename "$deb")"
            curl -fSL -O "$url"
            cd ..
            UPDATED=true
            echo "  → OK : $(basename "$url")"
        else
            echo "  → URL non disponible pour l'instant"
        fi
    else
        echo "  → Déjà à jour"
    fi
done

if [ "$UPDATED" = true ]; then
    echo ""
    echo "Mises à jour effectuées !"
else
    echo ""
    echo "Aucune mise à jour nécessaire."
fi
