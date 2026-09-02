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

echo "=== DWH Provisioning abgeschlossen ==="