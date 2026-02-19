# syntax=docker/dockerfile:1

# Étape builder : extrait les drivers Brother depuis les .deb locaux
FROM debian:bookworm-slim AS builder

ARG BRSCAN4_VERSION

COPY drivers/brscan4-${BRSCAN4_VERSION}.amd64.deb              /tmp/brscan4.deb
COPY drivers/brscan-skey-*.amd64.deb                           /tmp/brscan-skey.deb
COPY drivers/brother-udev-rule-*.all.deb                       /tmp/brother-udev-rule.deb

RUN set -eux && \
    echo "════════════════════════════════════════" && \
    echo "  📂 Fichiers .deb copiés dans /tmp/" && \
    echo "════════════════════════════════════════" && \
    ls -lh /tmp/*.deb && \
    echo "════════════════════════════════════════" && \
    echo "  📦 Extraction des drivers..." && \
    echo "════════════════════════════════════════" && \
    mkdir -p /extract && \
    dpkg-deb -x /tmp/brscan4.deb           /extract && echo "  ✅ brscan4           extrait" && \
    dpkg-deb -x /tmp/brscan-skey.deb       /extract && echo "  ✅ brscan-skey       extrait" && \
    dpkg-deb -x /tmp/brother-udev-rule.deb /extract && echo "  ✅ brother-udev-rule extrait" && \
    echo "════════════════════════════════════════" && \
    echo "  📁 Contenu extrait dans /extract/" && \
    echo "════════════════════════════════════════" && \
    find /extract -type f | sort && \
    echo "════════════════════════════════════════" && \
    rm -f /tmp/*.deb

# Image finale
FROM debian:bookworm-slim

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

COPY --from=builder /extract/usr/ /usr/
COPY --from=builder /extract/opt/ /opt/
COPY --from=builder /extract/etc/ /etc/

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
    mkdir -p /etc/opt/brother/scanner/brscan-skey \
             /opt/brother/scanner/brscan-skey \
             /scans \
    && \
    ln -sfn /opt/brother/docker_skey/config/brscan-skey.config \
            /etc/opt/brother/scanner/brscan-skey/brscan-skey.config 2>/dev/null || true

COPY scripts/      /opt/brother/docker_skey/scripts/
COPY config/       /opt/brother/docker_skey/config/

ARG PUID=1000
ARG PGID=1000
RUN if [ "${PUID}" != "0" ]; then \
        getent group scanner >/dev/null 2>&1 || groupadd -g "${PGID}" scanner; \
        getent passwd scanner >/dev/null 2>&1 || useradd -u "${PUID}" -g scanner -m -s /bin/false scanner; \
    fi

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/scans"]

ENTRYPOINT ["/entrypoint.sh"]

HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD sane-find-scanner >/dev/null && echo "OK" || exit 1
