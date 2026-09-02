# ETL-Server

## Ziel

Für die Übertragung der Daten aus dem operativen Sakila-System in das Data Warehouse wird ein separater ETL-Server eingesetzt.

Der Server trägt den Hostnamen `etl01` und stellt die technische Umgebung für die späteren Extract-, Transform- und Load-Prozesse bereit.

Durch die Verwendung eines separaten Servers werden die Aufgaben der operativen Datenhaltung, der Datenintegration und der analytischen Datenhaltung voneinander getrennt.

## Systemarchitektur

Die Projektarchitektur besteht aus drei virtuellen Maschinen.

```text
db-oltp01
192.168.56.11
PostgreSQL / Sakila OLTP
      |
      | Extract
      v
etl01
192.168.56.13
Python / ETL
      |
      | Load
      v
db-dwh01
192.168.56.12
PostgreSQL / Data Warehouse
```

Der ETL-Server befindet sich damit zwischen dem operativen Datenbanksystem und dem Data Warehouse.

## Systemkonfiguration

Der ETL-Server wird als virtuelle Maschine mit Vagrant bereitgestellt.

| Eigenschaft | Wert |
|---|---|
| Vagrant-Name | `etl` |
| Hostname | `etl01` |
| IP-Adresse | `192.168.56.13` |
| Betriebssystem | Debian 12 |
| Arbeitsspeicher | 2048 MB |
| CPUs | 2 |
| Aufgabe | ETL-Verarbeitung |

Die Konfiguration der virtuellen Maschine befindet sich im `Vagrantfile`.

## Provisioning

Die automatische Einrichtung des ETL-Servers erfolgt über:

```text
provisioning/etl.sh
```

Das Provisioning installiert die für die spätere Datenverarbeitung benötigten Pakete.

Dazu gehören:

- Python 3
- pip
- Python Virtual Environment
- PostgreSQL Client
- Git
- curl

Zusätzlich wird auf dem Server das Verzeichnis

```text
/opt/sakila-etl
```

für die ETL-Umgebung erstellt.

## Python-Umgebung

Für die Python-Abhängigkeiten des ETL-Prozesses wird ein eigenes Virtual Environment verwendet.

Dieses befindet sich unter:

```text
/opt/sakila-etl/venv
```

Das Virtual Environment trennt die Python-Pakete des Projekts von den global installierten Python-Paketen des Betriebssystems.

Für die Kommunikation mit PostgreSQL wird der Python-Treiber `psycopg2-binary` installiert.

Die Installation erfolgt automatisiert durch das Provisioning.

Der installierte PostgreSQL-Treiber kann mit folgendem Befehl überprüft werden:

```bash
source /opt/sakila-etl/venv/bin/activate
python3 -c "import psycopg2; print(psycopg2.__version__)"
```

## Netzwerk

Alle drei virtuellen Maschinen befinden sich in einem privaten Vagrant-Netzwerk.

Die verwendeten IP-Adressen sind:

| Server | IP-Adresse | Aufgabe |
|---|---|---|
| `db-oltp01` | `192.168.56.11` | Operative Sakila-Datenbank |
| `db-dwh01` | `192.168.56.12` | Data Warehouse |
| `etl01` | `192.168.56.13` | ETL-Verarbeitung |

Die Erreichbarkeit der Datenbankserver vom ETL-Server kann mit folgenden Befehlen überprüft werden:

```bash
ping -c 4 192.168.56.11
ping -c 4 192.168.56.12
```

## PostgreSQL-Netzwerkzugriff

Damit der ETL-Server auf die beiden PostgreSQL-Datenbanken zugreifen kann, wurden die PostgreSQL-Konfigurationen der Datenbankserver erweitert.

Der Zugriff wird dabei gezielt für die IP-Adresse des ETL-Servers freigegeben:

```text
192.168.56.13/32
```

Für die operative Datenbank wird der Zugriff auf folgende Kombination beschränkt:

```text
Datenbank: sakila_oltp
Benutzer:  sakila_app
Client:    192.168.56.13
```

Der Benutzer `sakila_app` besitzt Leserechte auf den benötigten Tabellen des operativen Systems.

Für das Data Warehouse wird der Zugriff auf folgende Kombination beschränkt:

```text
Datenbank: sakila_dwh
Benutzer:  dwh_app
Client:    192.168.56.13
```

Damit kann der ETL-Server später Daten aus dem OLTP-System lesen und Daten in das Data Warehouse schreiben.

## Verbindung zum OLTP-System

Die PostgreSQL-Verbindung vom ETL-Server zur operativen Sakila-Datenbank kann mit folgendem Befehl getestet werden:

```bash
psql -h 192.168.56.11 -U sakila_app -d sakila_oltp
```

Die Verbindung verwendet damit nicht die lokale PostgreSQL-Schnittstelle, sondern das private Netzwerk zwischen den virtuellen Maschinen.

Zur Kontrolle des Datenbestands kann beispielsweise folgende Abfrage verwendet werden:

```sql
SELECT COUNT(*) FROM rental;
```

Die Tabelle `rental` enthält:

```text
16044
```

Datensätze.

Damit steht dem ETL-Server ein lesender Zugriff auf die operative Datenquelle zur Verfügung.

## Verbindung zum Data Warehouse

Die Verbindung vom ETL-Server zum Data-Warehouse-Server kann mit folgendem Befehl getestet werden:

```bash
psql -h 192.168.56.12 -U dwh_app -d sakila_dwh
```

Zur Überprüfung kann die Faktentabelle abgefragt werden:

```sql
SELECT COUNT(*) FROM fact_rental;
```

Vor der erstmaligen Durchführung des ETL-Prozesses enthält die Faktentabelle noch keine Datensätze.

Das erwartete Ergebnis ist deshalb:

```text
0
```

## Python-Datenbankzugriff

Neben dem PostgreSQL-Kommandozeilenclient wird der Datenbankzugriff auch über Python vorbereitet.

Dafür wird die Bibliothek `psycopg2` verwendet.

Der ETL-Prozess kann damit später zwei getrennte Datenbankverbindungen aufbauen:

```text
Python / psycopg2
       |
       +------> db-oltp01 / sakila_oltp
       |
       +------> db-dwh01 / sakila_dwh
```

Die erste Verbindung dient zum Extrahieren der operativen Daten.

Die zweite Verbindung dient zum Laden der transformierten Daten in das Data Warehouse.

## Automatisierung

Die Einrichtung des ETL-Servers ist über Vagrant und das Provisioning-Skript automatisiert.

Die virtuelle Maschine kann mit folgendem Befehl erstellt werden:

```bash
vagrant up etl
```

Dabei werden das Betriebssystem und die benötigten Softwarekomponenten automatisch eingerichtet.

Die ETL-VM kann dadurch unabhängig von einer bereits vorhandenen virtuellen Maschine erneut aufgebaut werden.

## Abgrenzung zum ETL-Prozess

In diesem Schritt wurde ausschließlich die technische ETL-Infrastruktur aufgebaut.

Die eigentliche Transformation und Übertragung der Sakila-Daten ist noch nicht Bestandteil dieses Schrittes.

Der aktuelle Datenfluss ist technisch vorbereitet:

```text
Sakila OLTP
     |
     | Verbindung vorhanden
     v
   etl01
     |
     | Verbindung vorhanden
     v
Sakila DWH
```

Im nächsten Schritt wird der eigentliche ETL-Prozess in Python implementiert.

Dabei werden die Daten aus `sakila_oltp` extrahiert, für das Sternschema transformiert und anschließend in `sakila_dwh` geladen.