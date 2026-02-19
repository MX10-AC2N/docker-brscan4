#!/usr/bin/env bash
set -e

echo "=== update-drivers.sh - TEST MINIMAL ==="
echo "Script lancé avec succès sur le runner GitHub"
echo "Date : $(date)"
echo "Répertoire courant : $(pwd)"
ls -la drivers/ 2>/dev/null || echo "Dossier drivers non trouvé"
echo "=== TEST RÉUSSI ==="
exit 0