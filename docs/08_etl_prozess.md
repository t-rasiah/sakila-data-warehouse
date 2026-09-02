# ETL-Prozess

## Ziel

Der ETL-Prozess überträgt die operativen Daten aus der Sakila-Datenbank in das zuvor erstellte Data Warehouse.

Der Prozess wird auf dem separaten ETL-Server `etl01` mit Python ausgeführt.

Dabei werden die drei klassischen ETL-Phasen umgesetzt:

```text
Extract
   |
   v
Transform
   |
   v
Load
```

Die Quelldaten befinden sich auf `db-oltp01` in der Datenbank `sakila_oltp`.

Die transformierten Daten werden auf `db-dwh01` in die Datenbank `sakila_dwh` geladen.

## Architektur

Der Datenfluss erfolgt über die drei getrennten virtuellen Maschinen:

```text
db-oltp01
192.168.56.11
sakila_oltp
     |
     | Extract
     v
etl01
192.168.56.13
Python
     |
     | Transform / Load
     v
db-dwh01
192.168.56.12
sakila_dwh
```

Dadurch sind operative Datenhaltung, Datenintegration und analytische Datenhaltung voneinander getrennt.

## Python-Implementierung

Der ETL-Prozess wurde in Python implementiert.

Das zentrale Skript befindet sich unter:

```text
etl/load_dwh.py
```

Für den Zugriff auf PostgreSQL wird die Python-Bibliothek `psycopg2` verwendet.

Der ETL-Prozess baut zwei Datenbankverbindungen auf:

```text
OLTP-Verbindung
etl01 -> db-oltp01 -> sakila_oltp

DWH-Verbindung
etl01 -> db-dwh01 -> sakila_dwh
```

## Ablauf

Der ETL-Prozess lädt die Tabellen in folgender Reihenfolge:

```text
1. dim_date
2. dim_customer
3. dim_film
4. dim_store
5. fact_rental
```

Die Dimensionstabellen werden vor der Faktentabelle geladen, da `fact_rental` über Fremdschlüssel auf die Dimensionen verweist.

## Extract

In der Extract-Phase werden die benötigten Daten aus der normalisierten Sakila-Datenbank gelesen.

Dabei werden unter anderem folgende operative Tabellen verwendet:

```text
rental
payment
inventory
customer
film
film_category
category
store
address
city
country
```

Die Quelldaten bleiben dabei unverändert. Der Benutzer `sakila_app` besitzt auf dem operativen System nur die für den ETL-Prozess benötigten Leserechte.

## Transformation der Zeitdimension

Aus den Vermietungsdaten werden die unterschiedlichen Vermietungsdaten extrahiert.

Für jedes Datum wird ein numerischer Schlüssel im Format `YYYYMMDD` erzeugt.

Beispielsweise:

```text
2005-05-24 -> 20050524
```

Zusätzlich werden Attribute für analytische Zeitabfragen erzeugt:

```text
Tag
Monat
Monatsname
Quartal
Jahr
Wochentag
```

Diese Daten werden in `dim_date` geladen.

Beim getesteten Datenbestand wurden 41 unterschiedliche Datumswerte verarbeitet.

## Transformation der Kundendimension

Für `dim_customer` werden Daten aus mehreren Tabellen des OLTP-Systems kombiniert.

Dabei werden unter anderem folgende Informationen übernommen:

```text
customer_id
first_name
last_name
city
country
active
```

Das Feld `active` liegt in der Quelle als numerischer Wert vor und wird während der Transformation in einen booleschen Wert für das Data Warehouse umgewandelt.

Die ursprüngliche `customer_id` bleibt als fachlicher Quellschlüssel erhalten. Zusätzlich verwendet das Data Warehouse einen eigenen Surrogate Key `customer_key`.

Beim ETL-Test wurden 599 Kunden verarbeitet.

## Transformation der Filmdimension

Die Filmdimension kombiniert Informationen aus den Tabellen `film`, `film_category` und `category`.

Dadurch werden unter anderem folgende Attribute in einer Dimension zusammengeführt:

```text
film_id
title
category
rating
rental_rate
length
```

Die Kategorie wird direkt in `dim_film` gespeichert. Dadurch können spätere analytische Abfragen nach Filmkategorien ohne zusätzliche Joins zu einer separaten Kategoriedimension durchgeführt werden.

Beim ETL-Test wurden 1000 Filme verarbeitet.

## Transformation der Filialdimension

Für `dim_store` werden die Filialinformationen mit den zugehörigen Adress-, Stadt- und Länderdaten kombiniert.

Die Dimension enthält:

```text
store_id
city
country
```

Beim ETL-Test wurden 2 Filialen verarbeitet.

## Laden der Faktentabelle

Nach dem Laden der Dimensionen wird die zentrale Faktentabelle `fact_rental` aufgebaut.

Die Daten stammen hauptsächlich aus den Tabellen:

```text
rental
inventory
payment
```

Über `inventory` wird ermittelt, welcher Film und welche Filiale zu einer Vermietung gehören.

Die Faktentabelle enthält unter anderem:

```text
rental_id
date_key
customer_key
film_key
store_key
rental_count
amount
rental_duration
```

Die ursprünglichen Schlüssel aus dem OLTP-System werden dabei auf die Surrogate Keys der Dimensionstabellen abgebildet.

## Kennzahlen

Die Faktentabelle enthält mehrere Kennzahlen für spätere Analysen.

### rental_count

Jeder Vermietungsvorgang erhält:

```text
rental_count = 1
```

Dadurch kann die Anzahl der Vermietungen über eine Summenaggregation berechnet werden.

### amount

Die Zahlungen einer Vermietung werden aus der Tabelle `payment` übernommen beziehungsweise aggregiert.

Dadurch können Umsatzanalysen durchgeführt werden.

### rental_duration

Wenn ein Rückgabedatum vorhanden ist, wird aus `rental_date` und `return_date` die Vermietungsdauer berechnet.

Diese Kennzahl ermöglicht spätere Analysen der Vermietungsdauer.

## Idempotenz

Der ETL-Prozess wurde so entwickelt, dass Dimensionseinträge bei einem erneuten Lauf nicht unkontrolliert dupliziert werden.

Dafür werden PostgreSQL-Operationen mit `ON CONFLICT` verwendet.

Beispielsweise können vorhandene Dimensionseinträge aktualisiert werden, während neue Einträge eingefügt werden.

Für die Faktentabelle wird die ursprüngliche `rental_id` als eindeutiger Quellschlüssel verwendet.

Dadurch kann ein bereits vorhandener Vermietungsvorgang bei einem erneuten ETL-Lauf aktualisiert werden, anstatt einen zweiten Faktendatensatz zu erzeugen.

## Fehlerbehebung während der Entwicklung

Während der Entwicklung wurden die einzelnen ETL-Schritte separat getestet.

Dabei wurde unter anderem festgestellt, dass das Feld `active` aus der operativen Kundentabelle als numerischer Wert geliefert wird, während das Data Warehouse einen booleschen Datentyp verwendet.

Die Transformation wurde entsprechend angepasst:

```sql
(c.active = 1) AS active
```

Zusätzlich wurden die SQL-Anweisungen für das Laden der Faktentabelle überprüft und korrigiert.

Das schrittweise Testen der Dimensionen vor dem Laden der Faktentabelle erleichterte dabei die Fehleranalyse.

## Erfolgreicher ETL-Lauf

Nach der Implementierung konnte der vollständige ETL-Prozess erfolgreich ausgeführt werden.

Der Lauf lieferte folgende Ergebnisse:

```text
OLTP rental: 16044
DWH fact_rental vor dem Laden: 0

dim_date geladen: 41 Datumswerte
dim_customer geladen: 599 Kunden
dim_film geladen: 1000 Filme
dim_store geladen: 2 Filialen
fact_rental geladen: 16044 Vermietungen
```

Der ETL-Prozess wurde vollständig abgeschlossen.

Damit wurden die operativen Sakila-Daten erfolgreich in das dimensionale Data-Warehouse-Modell übertragen.

## Ausführung

Der ETL-Prozess wird auf `etl01` innerhalb des Python Virtual Environment ausgeführt.

```bash
source /opt/sakila-etl/venv/bin/activate
cd /vagrant
python3 etl/load_dwh.py
```

Das Skript stellt anschließend die Verbindungen zu beiden Datenbankservern her und führt die einzelnen ETL-Schritte in der definierten Reihenfolge aus.

## Ergebnis

Nach dem erfolgreichen ETL-Lauf steht ein befülltes Sternschema für analytische Abfragen zur Verfügung.

Der Datenfluss ist damit vollständig umgesetzt:

```text
Sakila OLTP
     |
     | Extract
     v
Python ETL
     |
     | Transform
     v
Dimensionen und Fakten
     |
     | Load
     v
Sakila Data Warehouse
```

Auf dieser Grundlage können im nächsten Schritt OLAP-Abfragen und analytische Auswertungen durchgeführt werden.