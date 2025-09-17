#!/bin/sh

ODOO_CONFIG="/usr/local/etc/odoo/odoo.conf"
ODOO_ADMIN_PASSWD="${ODOO_ADMIN_PASSWD:-admin}"; export ODOO_ADMIN_PASSWD
ODOO_DB_HOST="${ODOO_DB_HOST:-postgres}"; export ODOO_DB_HOST
ODOO_DB_PORT="${ODOO_DB_PORT:-5432}"; export ODOO_DB_PORT
ODOO_DB_USER="${ODOO_DB_USER:-odoo}"; export ODOO_DB_USER
ODOO_DB_PASSWORD="${ODOO_DB_PASSWORD:-odoo}"; export ODOO_DB_PASSWORD

set -e
set -o pipefail

env | grep -Ee '^ODOO_[A-Z0-9_]+=.*$' | while IFS= read -r env; do
    env_key=`printf "%s" "${env}" | sed -Ee 's/^ODOO_([A-Z0-9_]+)=.*$/\1/'`
    env_value=`printf "%s" "${env}" | cut -s -d "=" -f2-`

    env_key=`printf "%s" "${env_key}" | tr '[:upper:]' '[:lower:]'`

    initool s "${ODOO_CONFIG}" "options" "${env_key}" "${env_value}" > "${ODOO_CONFIG}.tmp" &&
        mv "${ODOO_CONFIG}.tmp" "${ODOO_CONFIG}" || exit $?
done

chown odoo:odoo "${ODOO_CONFIG}"
