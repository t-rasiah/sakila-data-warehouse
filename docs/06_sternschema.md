# Sternschema

## Ziel

Für die analytische Datenhaltung wird in der Datenbank `sakila_dwh` ein dimensionales Datenmodell umgesetzt.

Im Gegensatz zum normalisierten OLTP-Modell der Sakila-Datenbank wird das Data Warehouse für analytische Abfragen strukturiert.

Als Modellierungsform wird ein Sternschema verwendet.

## Fachlicher Schwerpunkt

Das Data Warehouse soll die Analyse von Vermietungen und den damit verbundenen Umsätzen ermöglichen.

Unter anderem sollen später folgende Fragestellungen analysiert werden können:

- Anzahl der Vermietungen nach Zeitraum
- Umsatz nach Zeitraum
- Umsatz nach Filiale
- Umsatz nach Film
- Umsatz nach Filmkategorie
- Vermietungen nach Kunde
- Vergleich verschiedener Filialen

## Granularität

Die Granularität der Faktentabelle legt fest, was eine einzelne Zeile der Faktentabelle repräsentiert.

Für dieses Projekt wurde folgende Granularität definiert:

Eine Zeile in `fact_rental` repräsentiert einen Vermietungsvorgang eines Films an einen Kunden.

Diese Granularität bildet die Grundlage für die Dimensionen und Kennzahlen des Data Warehouse.

## Sternschema

Das entwickelte Sternschema besteht aus einer zentralen Faktentabelle und vier Dimensionstabellen.

```text
                    dim_date
                       |
                       |
                       v
                 fact_rental
                 /     |     \
                /      |      \
               v       v       v
      dim_customer  dim_film  dim_store
```

Die zentrale Faktentabelle lautet:

```text
fact_rental
```

Die Dimensionen sind:

- `dim_date`
- `dim_customer`
- `dim_film`
- `dim_store`

## Zeitdimension

Die Tabelle `dim_date` stellt die Zeitdimension des Data Warehouse dar.

Sie enthält Attribute für die zeitliche Analyse der Vermietungen und Umsätze.

Zu den vorgesehenen Attributen gehören:

- Datum
- Tag
- Monat
- Monatsname
- Quartal
- Jahr
- Wochentag

Damit können Kennzahlen später auf unterschiedlichen zeitlichen Ebenen ausgewertet werden.

## Kundendimension

Die Tabelle `dim_customer` enthält Informationen zu den Kunden.

Neben den Kundendaten aus dem operativen System wird ein eigener Data-Warehouse-Schlüssel verwendet.

Der Schlüssel `customer_key` ist ein Surrogate Key des Data Warehouse.

Die ursprüngliche `customer_id` aus Sakila bleibt zusätzlich erhalten.

## Filmdimension

Die Tabelle `dim_film` enthält Informationen zu den Filmen.

Dazu gehören unter anderem:

- Titel
- Kategorie
- Altersfreigabe
- Mietpreis
- Filmlänge

Die Kategorie wird direkt in die Filmdimension übernommen, um analytische Abfragen nach Filmkategorien zu vereinfachen.

## Filialdimension

Die Tabelle `dim_store` beschreibt die Filialen.

Neben der ursprünglichen `store_id` werden geografische Informationen wie Stadt und Land für spätere Analysen gespeichert.

## Faktentabelle

Die Tabelle `fact_rental` bildet das Zentrum des Sternschemas.

Sie enthält Verweise auf die Dimensionen:

```text
date_key
customer_key
film_key
store_key
```

Zusätzlich enthält sie Kennzahlen für die Analyse:

```text
rental_count
amount
rental_duration
```

`rental_count` erhält für jeden Vermietungsvorgang den Wert `1`. Dadurch kann die Anzahl der Vermietungen später mit einer Summenaggregation bestimmt werden.

`amount` dient zur Analyse des Umsatzes.

`rental_duration` ermöglicht Auswertungen über die Dauer einer Vermietung.

## Surrogate Keys

Für die Dimensionstabellen werden eigene Data-Warehouse-Schlüssel verwendet.

Beispielsweise enthält `dim_customer` sowohl:

```text
customer_key
customer_id
```

`customer_key` ist der interne Schlüssel des Data Warehouse.

`customer_id` entspricht dem ursprünglichen Schlüssel des OLTP-Systems.

Dadurch bleibt die technische Schlüsselstruktur des Data Warehouse vom operativen System getrennt.

## Technische Umsetzung

Das Sternschema wird mit der SQL-Datei

```text
sql/dwh/01_star_schema.sql
```

erstellt.

Die Datei erstellt zunächst die Dimensionstabellen und anschließend die Faktentabelle mit den benötigten Fremdschlüsselbeziehungen.

## Automatisierung

Die Erstellung des Sternschemas wurde in das Provisioning des Data-Warehouse-Servers integriert.

Das Provisioning prüft zunächst, ob die Tabelle `fact_rental` bereits vorhanden ist.

Ist das Schema noch nicht vorhanden, wird `01_star_schema.sql` automatisch ausgeführt.

Die Tabellen werden anschließend dem Datenbankbenutzer `dwh_app` zugeordnet.

## Reproduzierbarkeit

Zur Überprüfung wurde die virtuelle Maschine `dwh` vollständig gelöscht und anschließend neu erstellt.

```bash
vagrant destroy dwh
vagrant up dwh
```

Nach dem Neuaufbau waren die vier Dimensionstabellen und die Faktentabelle automatisch vorhanden.

Die Tabellen waren zu diesem Zeitpunkt leer, da noch kein ETL-Prozess ausgeführt wurde.

Damit wurde der reproduzierbare Aufbau des Data-Warehouse-Schemas erfolgreich überprüft.