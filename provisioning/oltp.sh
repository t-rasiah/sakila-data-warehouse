#!/usr/bin/env bash

set -e

echo "=== OLTP Provisioning gestartet ==="

echo "=== Paketlisten aktualisieren ==="
apt-get update

echo "=== PostgreSQL installieren ==="
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  postgresql \
  postgresql-contrib

echo "=== PostgreSQL starten ==="
systemctl enable postgresql
systemctl start postgresql

echo "=== PostgreSQL Status prüfen ==="
pg_lsclusters

echo "=== Rolle sakila_app erstellen ==="

sudo -u postgres psql <<'SQL'
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE rolname = 'sakila_app'
   ) THEN
      CREATE ROLE sakila_app
      LOGIN
      PASSWORD 'sakila_app_pw';
   END IF;
END
$do$;
SQL

echo "=== Datenbank sakila_oltp erstellen ==="

if ! sudo -u postgres psql -tAc \
  "SELECT 1 FROM pg_database WHERE datname='sakila_oltp'" | grep -q 1
then
    sudo -u postgres createdb \
      --owner=sakila_app \
      sakila_oltp
fi

echo "=== Datenbank prüfen ==="

sudo -u postgres psql -c "\l"

echo "=== Sakila-Datenbank prüfen ==="

SAKILA_EXISTS=$(sudo -u postgres psql \
  -d sakila_oltp \
  -tAc "SELECT to_regclass('public.actor') IS NOT NULL;")

if [ "$SAKILA_EXISTS" != "t" ]; then

    echo "=== Sakila-Schema importieren ==="

    sudo -u postgres psql \
      -v ON_ERROR_STOP=1 \
      -d sakila_oltp \
      -f /vagrant/sql/oltp/postgres-sakila-schema.sql

    echo "=== Sakila-Daten importieren ==="

    sudo -u postgres psql \
      -v ON_ERROR_STOP=1 \
      -d sakila_oltp \
      -f /vagrant/sql/oltp/postgres-sakila-insert-data.sql

else

    echo "Sakila ist bereits vorhanden. Import wird übersprungen."

fi

echo "=== Leserechte für sakila_app setzen ==="

sudo -u postgres psql -d sakila_oltp <<'SQL'
GRANT USAGE ON SCHEMA public TO sakila_app;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO sakila_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO sakila_app;
SQL


echo "=== PostgreSQL Netzwerkzugriff konfigurieren ==="

PG_VERSION=$(pg_lsclusters --no-header | awk '{print $1}' | head -n 1)
PG_CONF="/etc/postgresql/${PG_VERSION}/main/postgresql.conf"
PG_HBA="/etc/postgresql/${PG_VERSION}/main/pg_hba.conf"

sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
sed -i "s/^listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

if ! grep -q "192.168.56.13/32.*sakila_app" "$PG_HBA"; then
    echo "host    sakila_oltp    sakila_app    192.168.56.13/32    scram-sha-256" >> "$PG_HBA"
fi

systemctl restart postgresql

echo "=== OLTP Provisioning abgeschlossen ==="