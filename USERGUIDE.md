# Guide d'utilisation - docker-brscan4

Ce container fournit le backend SANE **brscan4** de Brother dans un environnement Docker léger (basé sur Debian bookworm-slim, \~100 Mo compressé).

## Prérequis

- Docker installé
- Imprimante/scanner Brother **compatible brscan4** (modèles \~2010-2020 principalement)
- Scanner connecté en réseau (IP fixe ou DHCP-réservée recommandée) → **pas de support USB dans ce container pour l'instant**

## Étape 1 : Identifier votre modèle exact

1. Allez sur https://support.brother.com
2. Entrez votre modèle (ex. MFC-L2700DW)
3. Sélectionnez votre OS → Linux → Scanner Driver
4. Si "Scanner Driver (brscan4)" est proposé → votre modèle est compatible
5. Notez le **nom exact** (ex. MFC-L2700DW, DCP-L2540DW, etc.) – c'est sensible à la casse et aux tirets !

**Astuce** : Si vous avez déjà installé brscan4 sur une machine Linux, lancez :
```bash
brsaneconfig4 -q