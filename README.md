# Sakila Data Warehouse & OLAP

## Modulararbeit Datenbankdesign und Big Data

Dieses Repository enthält die praktische Umsetzung eines Data-Warehouse-Systems auf Basis der Sakila-Datenbank.

## Projektziel

Ziel dieses Projekts ist die Konzeption und Implementierung eines reproduzierbaren Data-Warehouse-Systems.

Die Infrastruktur wird mit Vagrant aufgebaut und besteht aus mehreren Linux-Systemen.

Das System umfasst:

- einen OLTP-Datenbankserver
- die Sakila-Datenbank als operative Datenquelle
- einen separaten ETL-Server
- einen Data-Warehouse-Datenbankserver
- PostgreSQL als Datenbanksystem
- einen ETL-Prozess
- ein dimensionales Datenmodell als Sternschema
- OLAP-Abfragen zur Analyse der Daten

## Geplante Architektur

| System | Hostname | IP-Adresse | Aufgabe |
|---|---|---|---|
| OLTP-Server | `db-oltp01` | `192.168.56.11` | PostgreSQL und Sakila |
| ETL-Server | `etl01` | `192.168.56.13` | Extraktion, Transformation und Laden |
| Data-Warehouse-Server | `db-dwh01` | `192.168.56.12` | PostgreSQL Data Warehouse |

Der geplante Datenfluss sieht folgendermassen aus:

```text
db-oltp01
PostgreSQL / Sakila
     |
     | Extract
     v
etl01
Python / ETL
     |
     | Transform / Load
     v
db-dwh01
PostgreSQL / Data Warehouse
     |
     v
OLAP-Abfragen
```

## Technologien

Für die Umsetzung werden folgende Technologien und Konzepte eingesetzt:

- Debian 12
- Vagrant
- VirtualBox
- PostgreSQL
- Sakila
- Python
- SQL
- Git und GitHub
- ETL
- Data Warehouse
- Sternschema
- OLAP

## Reproduzierbarkeit

Die virtuellen Maschinen selbst werden nicht im Git-Repository gespeichert.

Stattdessen werden der Vagrantfile, die Provisioning-Skripte, SQL-Skripte, Konfigurationen und der ETL-Quellcode versioniert.

Dadurch soll das vollständige System aus dem Git-Repository reproduziert werden können.

Der geplante Aufbau erfolgt mit:

```bash
git clone https://github.com/t-rasiah/sakila-data-warehouse.git
cd sakila-data-warehouse
vagrant up
```

## Repository-Struktur

Die aktuelle Struktur des Projekts ist:

```text
sakila-data-warehouse/
|
|-- README.md
|-- Vagrantfile
|-- .gitignore
|
|-- provisioning/
|   `-- oltp.sh
|
`-- docs/
    |-- 01_projektbeschreibung.md
    `-- 03_oltp_postgresql.md
```

Die Struktur wird während der weiteren Implementierung um die Komponenten für das Data Warehouse, den ETL-Prozess, SQL-Abfragen und Tests erweitert.

## Dokumentation

Die ausführliche Dokumentation der Modulararbeit befindet sich im Verzeichnis `docs`.

Die Dokumentation wird parallel zur praktischen Implementierung erstellt und beschreibt die einzelnen Schritte, technischen Entscheidungen, Konfigurationen und Tests.