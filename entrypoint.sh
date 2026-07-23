#!/usr/bin/env bash

. /lib.subr

set -e

create_user

chown -R noroot:noroot /data

python_version=`printf "%s" "${PYVER}" | sed -Ee 's/([0-9])([0-9]+)/\1.\2/'`
python_cmd="/usr/local/bin/python${python_version}"

if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
if [ "${USER:-root}" = "root" ]; then
    # Force because we are running this script as root.
    USER=odoo
fi
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    pg_var="${3:-}"
    if [ -n "$pg_var" ] && [[ -v "$pg_var" ]]; then
        return
    fi
    if ! grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then
        DB_ARGS+=("--${param}")
        DB_ARGS+=("${value}")
    fi;
}
check_config "db_host" "$HOST" "PGHOST"
check_config "db_port" "$PORT" "PGPORT"
check_config "db_user" "$USER" "PGUSER"
check_config "db_password" "$PASSWORD" "PGPASSWORD"

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec su-exec noroot odoo "$@"
        else
            su-exec noroot "${python_cmd}" /wait-for-psql.py ${DB_ARGS[@]} --timeout=30
            exec su-exec noroot odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        su-exec noroot "${python_cmd}" /wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        exec su-exec noroot odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1
