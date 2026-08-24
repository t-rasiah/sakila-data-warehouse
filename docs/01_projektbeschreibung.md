# Projektbeschreibung

## Ausgangslage

Im Rahmen der Modulararbeit wird ein Data-Warehouse-System konzipiert und praktisch implementiert.

Als operative Quelldatenbank wird die Sakila-Datenbank eingesetzt.

Die benötigte Infrastruktur wird mit Vagrant aufgebaut und besteht aus mehreren virtuellen Linux-Systemen.

## Ziel

Ziel der Arbeit ist der Aufbau eines reproduzierbaren Data-Warehouse-Systems.

Die operative Sakila-Datenbank wird auf einem separaten OLTP-Datenbankserver betrieben.

Die relevanten Daten werden über einen ETL-Prozess aus der operativen Datenbank extrahiert, transformiert und in ein separates Data Warehouse übertragen.

Das Data Warehouse wird für analytische Abfragen optimiert und verwendet ein dimensionales Datenmodell in Form eines Sternschemas.

Auf Basis der Daten im Data Warehouse werden anschliessend OLAP-Abfragen durchgeführt.

## Technische Hauptkomponenten

Für die Umsetzung werden folgende Technologien und Konzepte eingesetzt:

- Vagrant
- VirtualBox
- Debian 12
- PostgreSQL
- Sakila
- Python
- SQL
- Git
- GitHub
- ETL
- Data Warehouse
- Sternschema
- OLAP

## Systemarchitektur

Für das Projekt werden drei virtuelle Linux-Systeme eingesetzt.

| System | Hostname | IP-Adresse | Aufgabe |
|---|---|---|---|
| OLTP-Server | `db-oltp01` | `192.168.56.11` | Operative Sakila-Datenbank |
| ETL-Server | `etl01` | `192.168.56.13` | ETL-Verarbeitung |
| Data-Warehouse-Server | `db-dwh01` | `192.168.56.12` | Analytische Datenbank |

## OLTP-Server

Der Server `db-oltp01` stellt die operative Datenbank für das Projekt bereit.

Auf diesem System wird PostgreSQL als relationales Datenbanksystem eingesetzt.

Die Sakila-Datenbank wird in PostgreSQL importiert und dient als operative Datenquelle für den späteren ETL-Prozess.

Der Server verwendet die IP-Adresse `192.168.56.11`.

## ETL-Server

Der Server `etl01` wird für den ETL-Prozess eingesetzt.

ETL steht für Extract, Transform und Load.

Der Server übernimmt folgende Aufgaben:

- Extraktion der benötigten Daten aus der Sakila-Datenbank
- Transformation der Daten für das dimensionale Datenmodell
- Laden der transformierten Daten in das Data Warehouse

Der Server verwendet die IP-Adresse `192.168.56.13`.

## Data-Warehouse-Server

Der Server `db-dwh01` stellt das Data Warehouse bereit.

Das Data Warehouse wird ebenfalls mit PostgreSQL umgesetzt.

Im Gegensatz zur operativen Sakila-Datenbank wird das Datenmodell für analytische Abfragen optimiert.

Dafür wird ein dimensionales Datenmodell in Form eines Sternschemas entwickelt.

Der Server verwendet die IP-Adresse `192.168.56.12`.

## Datenfluss

Der geplante Datenfluss des Systems sieht folgendermassen aus:

```text
Sakila OLTP
db-oltp01
     |
     | Extract
     v
ETL-Prozess
etl01
     |
     | Transform
     | Load
     v
Data Warehouse
db-dwh01
     |
     v
OLAP-Abfragen
```

Die operative Datenhaltung und die analytische Datenhaltung werden dadurch voneinander getrennt.

## Reproduzierbarkeit

Ein wichtiges Ziel der Arbeit ist die Reproduzierbarkeit der gesamten Infrastruktur.

Die virtuellen Maschinen werden nicht direkt im Git-Repository gespeichert.

Stattdessen werden die notwendigen Definitionen und Konfigurationen versioniert.

Dazu gehören unter anderem:

- Vagrantfile
- Provisioning-Skripte
- SQL-Skripte
- ETL-Quellcode
- Konfigurationsdateien
- Tests
- Dokumentation

Dadurch soll es möglich sein, die benötigten virtuellen Maschinen aus dem Git-Repository neu zu erstellen.

Der geplante Ablauf ist:

```bash
git clone https://github.com/t-rasiah/sakila-data-warehouse.git
cd sakila-data-warehouse
vagrant up
```

Vagrant erstellt anschliessend die definierten virtuellen Maschinen und führt die hinterlegten Provisioning-Schritte aus.

## Ergebnis

Nach Abschluss der Modulararbeit soll ein funktionierendes und reproduzierbares Data-Warehouse-System vorhanden sein.

Die Sakila-Datenbank dient dabei als operatives OLTP-System. Die relevanten Daten werden über einen eigenen ETL-Prozess in ein separates Data Warehouse übertragen.

Das Data Warehouse wird anschliessend mit OLAP-Abfragen für analytische Auswertungen verwendet.