# OLAP-Abfragen und Analysen

## Ziel

Nach dem Aufbau und der Befüllung des Data Warehouse werden analytische Abfragen auf dem Sternschema durchgeführt.

Die Auswertungen basieren auf der Faktentabelle `fact_rental` sowie den Dimensionen für Zeit, Kunden, Filme und Filialen.

Ziel ist es, die im Data Warehouse gespeicherten Daten aus unterschiedlichen fachlichen Perspektiven zu analysieren.

## Grundlage

Das Sternschema besteht aus der Faktentabelle:

```text
fact_rental
```

und den Dimensionen:

```text
dim_date
dim_customer
dim_film
dim_store
```

Die Faktentabelle stellt Kennzahlen wie Anzahl Vermietungen, Umsatz und Vermietungsdauer bereit.

## Analytische Fragestellungen

Mit dem Data Warehouse werden unter anderem folgende Fragestellungen untersucht:

- Entwicklung von Umsatz und Vermietungen über die Zeit
- Umsatz nach Filmkategorie
- Vermietungen nach Filmkategorie
- Umsatzvergleich der Filialen
- Kunden mit dem höchsten Umsatz
- Filme mit den meisten Vermietungen
- Filme mit dem höchsten Umsatz
- durchschnittliche Vermietungsdauer
- geografische Auswertungen nach Kundenland

Die SQL-Abfragen befinden sich unter:

```text
sql/olap/01_analysen.sql
```

## Zeitliche Analyse

Die Zeitdimension ermöglicht Aggregationen nach unterschiedlichen Zeitebenen.

Beispielsweise kann der Umsatz nach Jahr und Monat ausgewertet werden.

```sql
SELECT
    d.year,
    d.month,
    SUM(f.amount) AS revenue
FROM fact_rental f
JOIN dim_date d
    ON f.date_key = d.date_key
GROUP BY
    d.year,
    d.month
ORDER BY
    d.year,
    d.month;
```

Dadurch können zeitliche Entwicklungen des Umsatzes analysiert werden.

## Roll-up

Beim Roll-up werden Detaildaten auf einer höheren Ebene aggregiert.

Beispielsweise kann eine monatliche Umsatzanalyse auf eine jährliche Ebene zusammengefasst werden.

Die verwendete Hierarchie lautet:

```text
Tag
 |
 v
Monat
 |
 v
Jahr
```

PostgreSQL unterstützt solche Aggregationen mit `ROLLUP`.

```sql
GROUP BY ROLLUP (
    d.year,
    d.month
)
```

Dadurch können Monatswerte, Jahreswerte und ein Gesamtergebnis innerhalb einer Abfrage erzeugt werden.

## Drill-down

Drill-down bezeichnet die Analyse von einer aggregierten Ebene zu einer detaillierteren Ebene.

Im Projekt kann beispielsweise von einer Jahresauswertung über den Monat bis zum einzelnen Datum navigiert werden.

```text
Jahr
 |
 v
Monat
 |
 v
Datum
```

Die Zeitdimension stellt die dafür benötigten Attribute bereit.

## CUBE

Zusätzlich wird die PostgreSQL-Funktion `CUBE` für multidimensionale Aggregationen eingesetzt.

Beispielsweise können Umsatzwerte gleichzeitig nach Jahr und Filiale analysiert werden.

```sql
GROUP BY CUBE (
    d.year,
    ds.store_id
)
```

Damit entstehen Aggregationen für verschiedene Kombinationen der Dimensionen, einschließlich Zwischensummen und Gesamtsummen.

## Analyse nach Filmkategorie

Die Filmdimension enthält die Kategorie eines Films.

Dadurch können Anzahl der Vermietungen und Umsatz direkt nach Kategorie aggregiert werden.

Diese Analyse zeigt, welche Kategorien besonders häufig vermietet werden und welche Kategorien den höchsten Umsatz generieren.

## Analyse nach Filiale

Über `dim_store` können die Vermietungen und Umsätze den einzelnen Filialen zugeordnet werden.

Dadurch können die beiden Filialen bezüglich Anzahl Vermietungen und Umsatz miteinander verglichen werden.

Zusätzlich kann die Filialdimension mit der Zeitdimension kombiniert werden, um die Entwicklung pro Filiale zu analysieren.

## Kundenanalyse

Über `dim_customer` können Vermietungen und Umsätze einzelnen Kunden zugeordnet werden.

Damit lassen sich beispielsweise die Kunden mit dem höchsten Gesamtumsatz bestimmen.

Die geografischen Attribute Stadt und Land ermöglichen zusätzliche regionale Auswertungen.

## Filmanalyse

Über `dim_film` können sowohl Vermietungsanzahl als auch Umsatz pro Film analysiert werden.

Dabei kann zwischen den am häufigsten vermieteten Filmen und den Filmen mit dem höchsten Umsatz unterschieden werden.

## Qualitätsprüfungen

Neben den analytischen Abfragen werden separate Qualitätsprüfungen durchgeführt.

Diese befinden sich unter:

```text
sql/olap/02_quality_checks.sql
```

Dabei werden unter anderem folgende Werte überprüft:

```text
Anzahl Faktendatensätze
Anzahl eindeutiger rental_id
Summe rental_count
Gesamtumsatz
ungültige Dimension Keys
```

Für die vier Dimensionen wird überprüft, ob Faktendatensätze ohne gültige Dimensionseinträge vorhanden sind.

Das erwartete Ergebnis ist jeweils:

```text
0
```

## Vergleich mit dem operativen System

Ein wichtiger Qualitätstest besteht im Vergleich der Anzahl der Vermietungen zwischen OLTP-System und Data Warehouse.

Im operativen System enthält die Tabelle `rental`:

```text
16044
```

Datensätze.

Nach dem ETL-Prozess enthält `fact_rental` ebenfalls:

```text
16044
```

Datensätze.

Damit kann nachvollzogen werden, dass alle Vermietungsvorgänge in das Data Warehouse übernommen wurden.

Zusätzlich kann der Gesamtumsatz der operativen Tabelle `payment` mit der Summe der Kennzahl `amount` in `fact_rental` verglichen werden.

## Ergebnis

Das Data Warehouse ermöglicht analytische Abfragen über mehrere Dimensionen.

Durch die Verwendung des Sternschemas können Kennzahlen mit vergleichsweise einfachen SQL-Abfragen nach Zeit, Kunde, Film, Kategorie und Filiale ausgewertet werden.

Mit `ROLLUP` und `CUBE` werden zusätzlich typische OLAP-Operationen direkt in PostgreSQL demonstriert.