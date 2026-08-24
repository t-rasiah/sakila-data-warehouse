\# Sakila Data Warehouse \& OLAP



\## Modulararbeit Datenbankdesign und Big Data



Dieses Repository enthält die praktische Umsetzung eines

Data-Warehouse-Systems auf Basis der Sakila-Datenbank.



\## Projektziel



Ziel des Projekts ist die Konzeption und Implementierung eines

reproduzierbaren Data-Warehouse-Systems.



Die Infrastruktur wird mit Vagrant aufgebaut und besteht aus

mehreren Linux-Systemen.



Das System umfasst:



\- einen OLTP-Datenbankserver

\- die Sakila-Datenbank als operative Datenquelle

\- einen separaten ETL-Server

\- einen Data-Warehouse-Datenbankserver

\- PostgreSQL als Datenbanksystem

\- einen ETL-Prozess

\- ein dimensionales Datenmodell als Sternschema

\- OLAP-Abfragen zur Analyse der Daten



\## Geplante Architektur



| System | Hostname | Aufgabe |

|---|---|---|

| OLTP Server | db-oltp01 | PostgreSQL und Sakila |

| ETL Server | etl01 | Extraktion, Transformation und Laden |

| Data Warehouse | db-dwh01 | PostgreSQL Data Warehouse |



\## Reproduzierbarkeit



Die virtuelle Infrastruktur wird mit Vagrant definiert.



Ziel ist es, dass das vollständige System aus diesem Git-Repository

reproduziert werden kann.

