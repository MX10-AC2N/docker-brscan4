#!/usr/bin/env bash
set -euo pipefail

# update-drivers.sh
# Met à jour les .deb Brother dans drivers/ si une version plus récente existe sur les serveurs Brother
# Usage : ./scripts/update-drivers.sh [--dry-run] [--verbose]

DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run) DRY_RUN=true; shift ;;
    --verbose) VERBOSE=true; shift ;;
    *) echo "Option inconnue : $1"; exit 1 ;;
  esac
done

cd "$(dirname "$0")/.." || exit 1   # remonte à la racine du repo

DRIVERS_DIR="drivers"
[ ! -d "$DRIVERS_DIR" ] && { echo "Dossier $DRIVERS_DIR introuvable"; exit 1; }

echo "Recherche de mises à jour dans $DRIVERS_DIR/"

UPDATED=false

# Fonction pour tester une URL et retourner son code HTTP
check_url() {
  curl -s -o /dev/null -w "%{http_code}" "$1"
}

# Boucle sur chaque .deb
for deb_file in "$DRIVERS_DIR"/*.deb; do
  [ ! -f "$deb_file" ] && continue

  echo "────────────────────────────────────────"
  echo "Fichier : $(basename "$deb_file")"

  # Extraction via dpkg-deb (doit être installé sur ta machine locale ou runner)
  pkg_name=\( (dpkg-deb --show --showformat=' \){Package}' "$deb_file" 2>/dev/null || basename "$deb_file" | sed 's/-.*//')
  current_version=\( (dpkg-deb --show --showformat=' \){Version}' "$deb_file" 2>/dev/null || echo "unknown")
  arch=\( (dpkg-deb --show --showformat=' \){Architecture}' "$deb_file" 2>/dev/null || basename "$deb_file" | grep -oE '(amd64|all|i386)' || echo "amd64")

  if [ "$current_version" = "unknown" ]; then
    echo "  Impossible d'extraire la version via dpkg-deb → skip"
    continue
  fi

  echo "  Paquet     : $pkg_name"
  echo "  Version    : $current_version"
  echo "  Arch       : $arch"

  # Configuration par paquet
  case "$pkg_name" in
    brscan4)
      base_urls=(
        "https://download.brother.com/welcome/dlf105200/"
        "https://download.brother.com/welcome/dlf105203/"
        "https://download.brother.com/welcome/dlf006645/"
      )
      candidates=("0.4.11-1" "0.4.12-1" "0.4.13-1" "0.5.0-1")
      filename_pattern="brscan4-%s.${arch}.deb"
      ;;
    brscan-skey)
      base_urls=(
        "https://download.brother.com/welcome/dlf006652/"
        "https://download.brother.com/welcome/dlf105204/"
        "https://download.brother.com/welcome/dlf006649/"
      )
      candidates=("0.3.2-0" "0.3.3-0" "0.3.4-0" "0.3.5-0")
      filename_pattern="brscan-skey-%s.${arch}.deb"
      ;;
    brother-udev-rule-type1)
      base_urls=(
        "https://download.brother.com/welcome/dlf006893/"
        "https://download.brother.com/welcome/dlf006894/"
      )
      candidates=("1.0.2-0" "1.0.3-0" "1.1.0-0")
      filename_pattern="brother-udev-rule-type1-%s.${arch}.deb"
      ;;
    *)
      echo "  Type non géré → skip"
      continue
      ;;
  esac

  latest_version=""
  latest_url=""

  # Recherche
  for candidate in "${candidates[@]}"; do
    for base_url in "${base_urls[@]}"; do
      candidate_url="\( {base_url} \)(printf "$filename_pattern" "$candidate")"
      [ "$VERBOSE" = true ] && echo "  Test : $candidate_url"
      http_code=$(check_url "$candidate_url")
      [ "$VERBOSE" = true ] && echo "    → $http_code"
      if [ "$http_code" = "200" ]; then
        if [ "$candidate" != "$current_version" ]; then
          latest_version="$candidate"
          latest_url="$candidate_url"
          echo "  → Nouvelle version trouvée : $latest_version"
          echo "     $latest_url"
          break 2
        else
          echo "  → Version actuelle déjà la plus récente"
          break 2
        fi
      fi
    done
  done

  if [ -n "$latest_version" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo "  → Mise à jour simulée (dry-run)"
    else
      cd "$DRIVERS_DIR"
      old_filename=$(basename "$deb_file")
      rm -f "$old_filename" || true
      curl -fSL -O "$latest_url" || { echo "Échec téléchargement"; exit 1; }
      cd ..
      UPDATED=true
      echo "  → Mise à jour : $old_filename → $(basename "$latest_url")"
    fi
  else
    echo "  → Pas de mise à jour"
  fi
done

if [ "$UPDATED" = true ]; then
  echo ""
  echo "Au moins une mise à jour a été effectuée."
  exit 0   # succès → workflow pourra commiter
else
  echo ""
  echo "Aucune mise à jour nécessaire."
  exit 0   # pas d'erreur, mais rien à commiter
fi