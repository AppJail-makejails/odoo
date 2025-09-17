# Odoo

Odoo is a business management software suite developed in Belgium. It includes modules for customer relationship management, e-commerce, billing, accounting, manufacturing, warehouse operations, project management, and inventory management. 

wikipedia.org/wiki/Odoo

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Odoo_Official_Logo.png/330px-Odoo_Official_Logo.png" alt="odoo logo" width="60%" height="auto">

## How to use this Makejail

This image requires a running PostgreSQL server.

### Start a PostgreSQL server

```console
$ appjail makejail \
      -j postgres \
      -f gh+AppJail-makejails/postgres \
      -o virtualnet=":<random> default" \
      -o nat \
      -o template="$PWD/template.conf" \
      -V POSTGRES_DB="odoo" \
      -V POSTGRES_USER="odoo" \
      -V POSTGRES_PASSWORD="odoo"
```

**template.conf**:

```
exec.start: "/bin/sh /etc/rc"
exec.stop: "/bin/sh /etc/rc.shutdown jail"
sysvmsg: new
sysvsem: new
sysvshm: new
mount.devfs
```

### Start an Odoo instance

```console
$ appjail makejail \
    -j odoo \
    -f gh+AppJail-makejails/odoo \
    -o virtualnet=":<random> default" \
    -o nat \
    -o expose=8069
```

You can configure Odoo through environment variables in the build stage of this Makejail by following these rules:

1. Environment variables must have the form: `ODOO_KEY_NAME`.
2. `KEY_NAME` must be in uppercase. They can contain `_` and numbers.

**Note**: For more advanced use cases, use the `odoo_config` argument.

### Arguments

* `odoo_config` (default: `files/odoo.conf`): Initial Odoo configuration file.
* `odoo_ajspec` (default: `gh+AppJail-makejails/odoo`): Entry point where the `appjail-ajspec(5)` file is located.
* `odoo_database` (default: `odoo`): Database name.
* `odoo_tag` (default: `13.5`): see [#tags](#tags).

### Environment

* `ODOO_ADMIN_PASSWD` (default: `admin`): Master Password that protects the database management screens, which are used for tasks like creating, restoring, and deleting databases.
* `ODOO_DB_HOST` (default: `postgres`): Host for the database server.
* `ODOO_DB_PORT` (default: `5432`): Port the database listens on.
* `ODOO_DB_USER` (default: `odoo`): Database username.
* `ODOO_DB_PASSWORD` (default: `odoo`): Database password.

### Volumes

| Name      | Owner | Group | Perm | Type | Mountpoint    |
| --------- | ----- | ----- | ---- | ---- | ------------- |
| odoo-data | 267   | 267   | -    | -    | /var/lib/odoo |
| odoo-done | -     | -     | -    | -    | /.odoo-done   |

## Tags

| Tag                  | Arch     | Version            | Type   | `odoo_version` |
| -------------------- | -------- | ------------------ | ------ | -------------- |
| `13.5`           | `amd64`  | `13.5-RELEASE` | `thin` |       -        |
| `13.5-16` | `amd64`  | `13.5-RELEASE` | `thin` |   16    |
| `13.5-17` | `amd64`  | `13.5-RELEASE` | `thin` |   17    |
| `14.3`           | `amd64`  | `14.3-RELEASE` | `thin` |       -        |
| `14.3-16` | `amd64`  | `14.3-RELEASE` | `thin` |   16    |
| `14.3-17` | `amd64`  | `14.3-RELEASE` | `thin` |   17    |
