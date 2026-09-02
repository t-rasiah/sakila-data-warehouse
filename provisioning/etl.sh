#!/usr/bin/env bash

set -e

echo "=== ETL Provisioning gestartet ==="

echo "=== Paketlisten aktualisieren ==="
apt-get update

echo "=== Python und benötigte Pakete installieren ==="

DEBIAN_FRONTEND=noninteractive apt-get install -y \
  python3 \
  python3-pip \
  python3-venv \
  postgresql-client \
  curl \
  git

echo "=== Python-Version prüfen ==="
python3 --version

echo "=== pip-Version prüfen ==="
pip3 --version

echo "=== PostgreSQL Client prüfen ==="
psql --version

echo "=== ETL-Verzeichnis erstellen ==="

mkdir -p /opt/sakila-etl
chown -R vagrant:vagrant /opt/sakila-etl

echo "=== Python Virtual Environment erstellen ==="

if [ ! -d "/opt/sakila-etl/venv" ]; then
    sudo -u vagrant python3 -m venv /opt/sakila-etl/venv
fi

echo "=== Python-Abhängigkeiten installieren ==="

/opt/sakila-etl/venv/bin/pip install --upgrade pip
/opt/sakila-etl/venv/bin/pip install psycopg2-binary

echo "=== ETL Provisioning abgeschlossen ==="