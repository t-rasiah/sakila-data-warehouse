## Automatisierung der Installation

Nachdem die PostgreSQL-Installation zunächst manuell durchgeführt und
getestet wurde, wurden die notwendigen Schritte in ein
Provisioning-Skript übertragen.

Das Skript befindet sich unter:

    provisioning/oltp.sh

Vagrant führt das Skript während der Erstellung des OLTP-Servers
automatisch aus.

Dadurch werden unter anderem folgende Schritte automatisiert:

- Aktualisierung der Paketlisten
- Installation von PostgreSQL
- Aktivierung des PostgreSQL-Dienstes
- Erstellung der Datenbankrolle
- Erstellung der OLTP-Datenbank

## Idempotenz

Das Provisioning wurde so umgesetzt, dass bestehende Datenbankobjekte
vor einer erneuten Erstellung geprüft werden.

Dadurch kann das Provisioning mehrfach ausgeführt werden, ohne dass
die bereits vorhandene Datenbank oder Rolle zu einem Fehler führt.

## Reproduzierbarkeitstest

Zur Überprüfung wurde die virtuelle Maschine vollständig gelöscht:

    vagrant destroy oltp

Anschliessend wurde sie ausschliesslich anhand der im Git-Repository
gespeicherten Konfiguration neu erstellt:

    vagrant up oltp

Nach Abschluss des Provisionings wurden PostgreSQL, die Datenbank
`sakila_oltp` und die Rolle `sakila_app` überprüft.