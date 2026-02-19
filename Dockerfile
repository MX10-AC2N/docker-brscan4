# syntax=docker/dockerfile:1

# Étape 1 : Builder - Télécharge et extrait le .deb officiel Brother
FROM --platform=linux/amd64 debian:bookworm-slim AS builder

ARG BRSCAN4_VERSION="0.4.11-1"
ARG BRSCAN4_URL="https://download.brother.com/welcome/dlf105200/brscan4-${BRSCAN4_VERSION}.amd64.deb"

RUN set -eux; \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl; \
    mkdir -p /extract; \
    curl -fSL -o /tmp/brscan4.deb "${BRSCAN4_URL}"; \
    dpkg-deb -x /tmp/brscan4.deb /extract; \
    rm -f /tmp/brscan4.deb; \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*;

# Étape 2 : Image finale légère
FROM --platform=linux/amd64 debian:bookworm-slim

LABEL maintainer="MX10-AC2N" \
      org.opencontainers.image.source="https://github.com/MX10-AC2N/docker-brscan4" \
      org.opencontainers.image.description="Lightweight Brother brscan4 SANE backend (amd64)" \
      org.opencontainers.image.version="0.4.11"

ENV \
    SCANNER_NAME="BrotherScanner" \
    SCANNER_MODEL="" \
    SCANNER_IP_ADDRESS="" \
    TZ="Europe/Paris" \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# Copie les fichiers essentiels du driver Brother
COPY --from=builder /extract/usr/ /usr/
COPY --from=builder /extract/opt/ /opt/

# Installe les dépendances runtime minimales
RUN set -eux; \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        sane-utils \
        libusb-1.0-0 \
        libtiff6 \
        ca-certificates \
        tzdata \
    && \
    # Nettoyage ultra-agressif
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/* /var/tmp/* \
    && \
    # Répertoires et liens symboliques (adapte si tu as des configs custom pour brscan-skey)
    mkdir -p /etc/opt/brother/scanner/brscan-skey \
             /opt/brother/scanner/brscan-skey \
             /scans \
    && \
    ln -sfn /opt/brother/docker_skey/config/brscan-skey.config \
            /etc/opt/brother/scanner/brscan-skey/brscan-skey.config 2>/dev/null || true

# Copie tes dossiers custom (scripts, config, drivers si tu en as)
# → Crée ces dossiers dans ton repo si besoin, sinon supprime les lignes COPY
COPY scripts/      /opt/brother/docker_skey/scripts/
COPY config/       /opt/brother/docker_skey/config/
# COPY drivers/    /opt/brother/docker_skey/drivers/  # optionnel

# Création d'un utilisateur non-root (recommandé pour la sécurité)
ARG PUID=1000
ARG PGID=1000
RUN if [ "${PUID}" != "0" ]; then \
        groupadd -g "${PGID}" scanner && \
        useradd -u "\( {PUID}" -g " \){PGID}" -m -s /bin/false scanner; \
    fi

# Copie l'entrypoint qui valide les vars et configure le scanner
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/scans"]

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD sane-find-scanner >/dev/null && echo "OK" || exit 1