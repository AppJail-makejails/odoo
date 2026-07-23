ARG FREEBSD_RELEASE

FROM ghcr.io/appjail-makejails/core:${FREEBSD_RELEASE}

ARG PYVER
ARG ODOOVER
ARG NO_PKGCLEAN

LABEL org.opencontainers.image.title="Odoo" \
    org.opencontainers.image.description="Suite of web based open source business apps" \
    org.opencontainers.image.source="https://github.com/AppJail-makejails/odoo" \
    org.opencontainers.image.url="https://github.com/AppJail-makejails/odoo" \
    org.opencontainers.image.vendor="DtxdF" \
    org.opencontainers.image.authors="Jesús Daniel Colmenares Oviedo <dtxdf@disroot.org>"

RUN set -xe; \
    \
    pkg update; \
    pkg install -U py${PYVER}-odoo${ODOOVER} bash; \
    \
    if [ -z "${NO_PKGCLEAN}" ]; then \
        pkg clean -a; \
        rm -rf /var/cache/pkg/*; \
    fi; \
    rm -rf /var/db/pkg/repos/*

ENV PYVER=${PYVER}
ENV ODOO_RC=/usr/local/etc/odoo/odoo.conf

COPY entrypoint.sh /
COPY odoo.conf ${ODOO_RC}
COPY wait-for-psql.py /wait-for-psql.py

RUN chmod +x /entrypoint.sh && \
    mkdir -p /data /mnt/extra-addons && \
    chmod 755 /mnt/extra-addons

VOLUME ["/data", "/mnt/extra-addons"]

EXPOSE 8069 8071 8072

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
