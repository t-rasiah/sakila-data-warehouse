#!/usr/bin/env bash

set -e

echo "=== DWH Provisioning gestartet ==="

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

echo "=== Rolle dwh_app erstellen ==="

sudo -u postgres psql <<'SQL'
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE rolname = 'dwh_app'
   ) THEN
      CREATE ROLE dwh_app
      LOGIN
      PASSWORD 'dwh_app_pw';
   END IF;
END
$do$;
SQL

echo "=== Datenbank sakila_dwh erstellen ==="

if ! sudo -u postgres psql -tAc \
  "SELECT 1 FROM pg_database WHERE datname='sakila_dwh'" | grep -q 1
then
    sudo -u postgres createdb \
      --owner=dwh_app \
      sakila_dwh
fi

echo "=== Datenbank prüfen ==="

sudo -u postgres psql -c "\l"

echo "=== Data-Warehouse-Schema prüfen ==="

DWH_SCHEMA_EXISTS=$(sudo -u postgres psql \
  -d sakila_dwh \
  -tAc "SELECT to_regclass('public.fact_rental') IS NOT NULL;")

if [ "$DWH_SCHEMA_EXISTS" != "t" ]; then

    echo "=== Data-Warehouse-Schema erstellen ==="

    sudo -u postgres psql \
      -v ON_ERROR_STOP=1 \
      -d sakila_dwh \
      -f /vagrant/sql/dwh/01_star_schema.sql

    echo "=== Eigentümer der DWH-Tabellen setzen ==="

    sudo -u postgres psql -d sakila_dwh <<'SQL'
ALTER TABLE dim_date OWNER TO dwh_app;
ALTER TABLE dim_customer OWNER TO dwh_app;
ALTER TABLE dim_film OWNER TO dwh_app;
ALTER TABLE dim_store OWNER TO dwh_app;
ALTER TABLE fact_rental OWNER TO dwh_app;
SQL

else

    echo "Data-Warehouse-Schema ist bereits vorhanden."

fi

echo "=== PostgreSQL Netzwerkzugriff konfigurieren ==="

PG_VERSION=$(pg_lsclusters --no-header | awk '{print $1}' | head -n 1)
PG_CONF="/etc/postgresql/${PG_VERSION}/main/postgresql.conf"
PG_HBA="/etc/postgresql/${PG_VERSION}/main/pg_hba.conf"

sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
sed -i "s/^listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

if ! grep -q "192.168.56.13/32.*dwh_app" "$PG_HBA"; then
    echo "host    sakila_dwh    dwh_app    192.168.56.13/32    scram-sha-256" >> "$PG_HBA"
fi

systemctl restart postgresql

echo "=== DWH Provisioning abgeschlossen ==="