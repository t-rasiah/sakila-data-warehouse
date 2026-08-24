\# Projektbeschreibung



\## Ausgangslage



Im Rahmen der Modulararbeit wird ein Data-Warehouse-System

konzipiert und praktisch implementiert.



Als operative Quelldatenbank wird die Sakila-Datenbank eingesetzt.



\## Ziel



Die operative Sakila-Datenbank wird auf einem separaten

OLTP-Datenbankserver betrieben.



Die relevanten Daten werden über einen ETL-Prozess in ein separates

Data Warehouse übertragen.



Das Data Warehouse wird für analytische Abfragen optimiert und

verwendet ein dimensionales Datenmodell.



\## Technische Hauptkomponenten



\- Vagrant

\- Linux

\- PostgreSQL

\- Sakila

\- Python

\- SQL

\- Git

\- ETL

\- Data Warehouse

\- Sternschema

\- OLAP



\## Systeme



\### db-oltp01



Operatives PostgreSQL-Datenbanksystem mit der Sakila-Datenbank.



\### etl01



Separates Linux-System für den ETL-Prozess.



\### db-dwh01



PostgreSQL-Datenbanksystem für das analytische Data Warehouse.



