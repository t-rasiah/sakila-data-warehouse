# Sakila-Datenbank

## Ausgangslage

Als operative Datenquelle für das Projekt wird die Sakila-Datenbank verwendet.

Die Datenbank wird auf dem OLTP-Server `db-oltp01` in PostgreSQL betrieben. Die Datenbank trägt den Namen `sakila_oltp`.

Sakila stellt ein relationales Datenmodell eines DVD-Verleihsystems bereit und enthält unter anderem Daten zu Filmen, Kunden, Mitarbeitern, Filialen, Vermietungen und Zahlungen.

## SQL-Dateien

Für den Aufbau der Sakila-Datenbank werden eine PostgreSQL-Version des Datenbankschemas und die zugehörigen Beispieldaten verwendet.

Die benötigten SQL-Dateien befinden sich innerhalb des Projekts unter:

```text
sql/oltp/
```

Dabei werden zwei getrennte SQL-Dateien verwendet:

```text
postgres-sakila-schema.sql
postgres-sakila-insert-data.sql
```

Die erste Datei erstellt das Datenbankschema und die benötigten Datenbankobjekte.

Die zweite Datei enthält die Beispieldaten der Sakila-Datenbank.

Durch die Ablage der SQL-Dateien im Projekt stehen sie auch beim erneuten Aufbau der virtuellen Maschine zur Verfügung.

## Manueller Import

Vor der Automatisierung wurde der Import zunächst manuell durchgeführt.

Das Schema wurde mit folgendem Befehl importiert:

```bash
sudo -u postgres psql \
  -v ON_ERROR_STOP=1 \
  -d sakila_oltp \
  -f /vagrant/sql/oltp/postgres-sakila-schema.sql
```

Anschliessend wurden die Daten importiert:

```bash
sudo -u postgres psql \
  -v ON_ERROR_STOP=1 \
  -d sakila_oltp \
  -f /vagrant/sql/oltp/postgres-sakila-insert-data.sql
```

Mit der Option `ON_ERROR_STOP` wird der Import bei einem SQL-Fehler abgebrochen.

## Überprüfung des Datenbestands

Nach dem Import wurde der Datenbestand mit mehreren SQL-Abfragen überprüft.

```sql
SELECT COUNT(*) FROM actor;
SELECT COUNT(*) FROM film;
SELECT COUNT(*) FROM customer;
SELECT COUNT(*) FROM rental;
SELECT COUNT(*) FROM payment;
```

Dabei wurden folgende Datensatzmengen ermittelt:

| Tabelle | Datensätze |
|---|---:|
| `actor` | 200 |
| `film` | 1000 |
| `customer` | 599 |
| `rental` | 16044 |
| `payment` | 16049 |

Damit konnte überprüft werden, dass die für das Projekt relevanten Sakila-Daten vorhanden sind.

## Datenbankbenutzer

Für den Zugriff auf die operative Datenbank wurde der PostgreSQL-Benutzer `sakila_app` eingerichtet.

Der Benutzer besitzt Leserechte auf die Tabellen im Schema `public`.

Die notwendigen Rechte werden mit folgenden SQL-Befehlen gesetzt:

```sql
GRANT USAGE ON SCHEMA public TO sakila_app;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO sakila_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO sakila_app;
```

Der lesende Zugriff wurde anschliessend mit dem Benutzer `sakila_app` getestet.

## Automatisierung

Nach dem erfolgreichen manuellen Import wurde der Sakila-Import in das Provisioning des OLTP-Servers integriert.

Das dafür verwendete Skript befindet sich unter:

```text
provisioning/oltp.sh
```

Das Provisioning prüft zunächst, ob die Tabelle `actor` bereits vorhanden ist.

```sql
SELECT to_regclass('public.actor') IS NOT NULL;
```

Ist die Tabelle noch nicht vorhanden, werden das Sakila-Schema und die Sakila-Daten automatisch importiert.

Ist Sakila bereits vorhanden, wird der erneute Import übersprungen.

Dadurch kann das Provisioning mehrfach ausgeführt werden, ohne die Sakila-Daten bei jedem Durchlauf erneut zu importieren.

## Reproduzierbarkeitstest

Zum Abschluss wurde die virtuelle Maschine des OLTP-Servers vollständig gelöscht:

```bash
vagrant destroy oltp
```

Anschliessend wurde sie erneut aus der Vagrant-Konfiguration erstellt:

```bash
vagrant up oltp
```

Nach dem Neuaufbau waren PostgreSQL, die Datenbank `sakila_oltp`, der Benutzer `sakila_app` und die Sakila-Daten wieder vorhanden.

Die Datensatzmengen wurden erneut kontrolliert und entsprachen den zuvor ermittelten Werten.

Damit wurde der reproduzierbare Aufbau des OLTP-Systems erfolgreich getestet.