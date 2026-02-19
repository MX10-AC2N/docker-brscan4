# docker-brscan4

![Docker Image Size](https://img.shields.io/docker/image-size/mx10ac2n/docker-brscan4/latest?label=amd64%20size)

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/MX10-AC2N/docker-brscan4/auto-update-brscan4.yml?label=monthly%20update%20check)

Container Docker léger (~100 Mo) pour le backend SANE **brscan4** de Brother (scanner réseau).

Supporte les modèles compatibles brscan4 (ex. MFC-L2700DW, DCP-L2540DW, MFC-J5620DW, etc.).

**Version actuelle du driver Brother** : [BRSCAN4_VERSION](BRSCAN4_VERSION) (mise à jour automatique mensuelle si Brother publie une nouvelle version).

## Quick Start

1. Copie `.env.example` → `.env` et remplis au minimum :
   ```
   SCANNER_MODEL=MFC-L2700DW          # ← obligatoire, nom EXACT du modèle
   SCANNER_IP_ADDRESS=192.168.1.200   # ← obligatoire pour réseau
   SCANNER_NAME=MonScanner            # optionnel
   ```

2. Lance avec docker run :
   ```bash
   docker run -d \
     --name brscan4 \
     --restart unless-stopped \
     --network host \
     -v ~/Scans:/scans \
     --env-file .env \
     mx10ac2n/docker-brscan4:latest
   ```

   Ou avec **docker-compose** (recommandé) :
   ```yaml
   services:
     brscan4:
       image: mx10ac2n/docker-brscan4:latest
       container_name: brscan4
       restart: unless-stopped
       network_mode: host
       volumes:
         - ./scans:/scans
       env_file:
         - .env
   ```

3. Vérifie :
   ```bash
   docker logs brscan4
   scanimage -L   # doit lister ton scanner
   ```

## Documentation complète

→ [USERGUIDE.md](USERGUIDE.md) : Guide détaillé (modèles compatibles, dépannage, configuration avancée, etc.)

## Mise à jour automatique

Un workflow GitHub vérifie **1 fois par mois** si une nouvelle version de brscan4 existe sur les serveurs Brother.  
Si oui → mise à jour de `BRSCAN4_VERSION` + commit + tag Git (ex. `v0.4.12`).

## Build local (optionnel)

```bash
docker build -t mx10ac2n/docker-brscan4:test .
```

Questions / bugs → ouvre une issue !

Licence : MIT (fork libre du driver Brother propriétaire).