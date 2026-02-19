# syntax=docker/dockerfile:1

# Étape builder : télécharge et extrait le driver Brother
FROM debian:bookworm-slim AS builder

ARG BRSCAN4_VERSION

RUN set -eux && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl && \
    mkdir -p /extract && \
    # Essaie plusieurs miroirs/numéros DL connus
    ( curl -fSL -o /tmp/brscan4.deb "https://download.brother.com/welcome/dlf105200/brscan4-${BRSCAN4_VERSION}.amd64.deb" || \
      curl -fSL -o /tmp/brscan4.deb "https://download.brother.com/welcome/dlf105203/brscan4-${BRSCAN4_VERSION}.amd64.deb" || \
      { echo "Échec du téléchargement de brscan4 ${BRSCAN4_VERSION} sur les URLs connues"; exit 1; } ) && \
    dpkg-deb -x /tmp/brscan4.deb /extract && \
    rm -f /tmp/brscan4.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/*;

# Image finale
FROM debian:bookworm-slim

LABEL maintainer="MX10-AC2N" \
      org.opencontainers.image.source="https://github.com/MX10-AC2N/docker-brscan4" \
      org.opencontainers.image.description="Lightweight Brother brscan4 SANE backend (amd64)" \
      org.opencontainers.image.version="0.4.11"

# Variables d'environnement par défaut
ENV \
    SCANNER_NAME="BrotherScanner" \
    SCANNER_MODEL="" \
    SCANNER_IP_ADDRESS="" \
    TZ="Europe/Paris" \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

# Copie les fichiers extraits du driver
COPY --from=builder /extract/usr/ /usr/
COPY --from=builder /extract/opt/ /opt/

# Dépendances runtime minimales + nettoyage agressif
RUN set -eux && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        sane-utils \
        libusb-1.0-0 \
        libtiff6 \
        ca-certificates \
        tzdata \
    && \
    apt-get autoremove -y --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/* \
    && \
    # Création des répertoires et liens symboliques
    mkdir -p /etc/opt/brother/scanner/brscan-skey \
             /opt/brother/scanner/brscan-skey \
             /scans \
    && \
    ln -sfn /opt/brother/docker_skey/config/brscan-skey.config \
            /etc/opt/brother/scanner/brscan-skey/brscan-skey.config 2>/dev/null || true

# Copie tes dossiers personnalisés (supprime les lignes si les dossiers n'existent pas)
COPY scripts/      /opt/brother/docker_skey/scripts/
COPY config/       /opt/brother/docker_skey/config/
# COPY drivers/    /opt/brother/docker_skey/drivers/   # optionnel

# Création utilisateur non-root (idempotente)
ARG PUID=1000
ARG PGID=1000
RUN if [ "${PUID}" != "0" ]; then \
        getent group  scanner >/dev/null || groupadd -g "${PGID}" scanner; \
        getent passwd scanner >/dev/null || useradd -u "\( {PUID}" -g " \){PGID}" -m -s /bin/false scanner; \
    fi

# Copie l'entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/scans"]

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD sane-find-scanner >/dev/null && echo "OK" || exit 1