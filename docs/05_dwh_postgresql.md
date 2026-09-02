# Data-Warehouse-Datenbankserver

## Ziel

Für das Data Warehouse wird ein separater Datenbankserver eingesetzt.

Der Server trägt den Hostnamen `db-dwh01` und wird unabhängig vom operativen OLTP-System betrieben.

Dadurch werden die operative Datenhaltung und die analytische Datenhaltung voneinander getrennt.

## Systemkonfiguration

Der Data-Warehouse-Server wird als virtuelle Maschine mit Vagrant bereitgestellt.

| Eigenschaft | Wert |
|---|---|
| Vagrant-Name | `dwh` |
| Hostname | `db-dwh01` |
| IP-Adresse | `192.168.56.12` |
| Betriebssystem | Debian 12 |
| Arbeitsspeicher | 2048 MB |
| CPUs | 2 |
| Datenbanksystem | PostgreSQL |

Die Konfiguration der virtuellen Maschine befindet sich im `Vagrantfile`.

## Netzwerk

Der Data-Warehouse-Server verwendet die private IP-Adresse:

```text
192.168.56.12
```

Der OLTP-Server verwendet:

```text
192.168.56.11
```

Die Kommunikation zwischen den Systemen erfolgt über das private Vagrant-Netzwerk.

Die Netzwerkverbindung zwischen `db-dwh01` und `db-oltp01` wurde mit `ping` überprüft.

## PostgreSQL

Auf `db-dwh01` wird PostgreSQL als Datenbanksystem eingesetzt.

Die Installation erfolgt automatisiert über:

```text
provisioning/dwh.sh
```

Das Provisioning installiert die benötigten PostgreSQL-Pakete und startet den PostgreSQL-Dienst.

Der Zustand des PostgreSQL-Clusters kann mit folgendem Befehl überprüft werden:

```bash
pg_lsclusters
```

## Data-Warehouse-Datenbank

Für das Data Warehouse wurde eine eigene PostgreSQL-Datenbank erstellt.

```text
sakila_dwh
```

Zusätzlich wurde der Datenbankbenutzer erstellt:

```text
dwh_app
```

Die Datenbank wird mit `dwh_app` als Eigentümer erstellt.

## Verbindungstest

Die Anmeldung an der Data-Warehouse-Datenbank wurde mit folgendem Befehl getestet:

```bash
psql -h 127.0.0.1 -U dwh_app -d sakila_dwh
```

Innerhalb von PostgreSQL wurde anschließend die aktuelle Datenbank und der aktuelle Benutzer überprüft:

```sql
SELECT current_database(), current_user;
```

Das Ergebnis war:

```text
 current_database | current_user
------------------+-------------
 sakila_dwh       | dwh_app
```

Damit wurde bestätigt, dass die Datenbank und der zugehörige Benutzer korrekt eingerichtet wurden.

## Automatisierung

Die Installation und Grundkonfiguration des Data-Warehouse-Servers erfolgt über das Provisioning-Skript:

```text
provisioning/dwh.sh
```

Das Skript übernimmt unter anderem:

- Aktualisierung der Paketlisten
- Installation von PostgreSQL
- Aktivierung und Start des PostgreSQL-Dienstes
- Erstellung des Benutzers `dwh_app`
- Erstellung der Datenbank `sakila_dwh`

Dadurch kann die Grundkonfiguration des Data-Warehouse-Servers automatisch über Vagrant durchgeführt werden.

## Nächster Schritt

Die Datenbank `sakila_dwh` stellt zunächst eine leere Data-Warehouse-Datenbank bereit.

Im nächsten Schritt wird auf Basis der operativen Sakila-Daten ein dimensionales Datenmodell entwickelt.

Dabei werden die benötigten Fakten, Dimensionen und Beziehungen definiert und anschließend als Sternschema in PostgreSQL umgesetzt.

## Reproduzierbarkeitstest

Zur Überprüfung der Reproduzierbarkeit wurde die virtuelle Maschine des Data-Warehouse-Servers vollständig gelöscht:

```bash
vagrant destroy dwh