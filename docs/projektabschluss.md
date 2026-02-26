# Projektabschluss und Versionierung

**Modell: Opus (Pflicht)**

Ein Projekt endet nicht automatisch mit dem letzten Issue, sondern mit einer expliziten Abschluss-Phase durch Opus:

1. Opus prüft: Alle Akzeptanzkriterien aus Phase 1 erfüllt? Keine offenen Sub-Issues? Dokumentation vollständig?
2. Opus vergibt Versionsnummer (z.B. `v1.0`) und dokumentiert sie in CHANGELOG.md und MEMORY.md
3. Opus archiviert MEMORY.md als `MEMORY_v1.0.md` (Snapshot des Projektstands)
4. Abschluss-Commit: `release: v1.0 – Projektabschluss`
5. Opus-Pflichtmeldung: "Version v1.0 abgeschlossen. Neue Features → v2.0-Planung starten."

## Neue Features nach Abschluss
- Neue Features sind KEINE weiteren Issues der aktuellen Version
- Sie starten als neue Version (v2.0) wieder bei Phase 0 mit Opus
- Opus erstellt neue Mindmap, neue Issues, neues Kanban für v2.0
- `MEMORY_v1.0.md` bleibt als Referenz erhalten, `MEMORY.md` wird für v2.0 neu geführt

## Wartungsmodus (zwischen Versionen)
- Bugfixes an bestehender Version laufen als Patch (v1.1, v1.2)
- Patch-Entscheidung trifft Ruben, Umsetzung durch Sonnet
