## Idempotenz

Der ETL-Prozess wurde nach dem vollständigen Neuaufbau zweimal ausgeführt.

Nach dem ersten ETL-Lauf enthielt die Faktentabelle `fact_rental` 16'044 Datensätze.

Beim zweiten ETL-Lauf waren bereits 16'044 Datensätze vorhanden. Nach Abschluss des zweiten Laufs enthielt `fact_rental` weiterhin 16'044 Datensätze.

Damit wurde bestätigt, dass ein erneuter ETL-Lauf keine zusätzlichen Duplikate in der Faktentabelle erzeugt.

## Datenqualität

Nach dem ETL-Prozess wurden zusätzliche Qualitätsprüfungen durchgeführt.

Dabei ergaben sich folgende Werte:

```text
fact_rows               16044
unique_rentals          16044
rental_count            16044
total_revenue        67416.51

## Vergleich des Gesamtumsatzes

Zur Überprüfung der korrekten Datenübernahme wurde der Gesamtumsatz zwischen dem operativen Quellsystem und dem Data Warehouse verglichen.

Im OLTP-System wurde die Summe der Tabelle `payment` ermittelt:

```text
67416.51


## Prüfung der OLAP-Abfragen

Nach dem vollständigen Neuaufbau der Umgebung wurden sämtliche OLAP-Abfragen erneut ausgeführt.

Die Datei:

```text
sql/olap/01_analysen.sql