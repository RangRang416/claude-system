# Projekt-Start (Pflicht bei neuem Projekt)

Bei jedem neuen Projekt sofort:
1. GitHub-Repo anlegen (Synchronisation auf mehreren Geräten)
2. GitHub Project (Kanban-Board) zum Repo erstellen
3. Issues direkt im Kanban anlegen: Spalten → `Backlog / In Progress / Review / Done`
4. Mindmap erstellen unter `claude-projekt/mindmaps/projektname.md`
5. Mindmap Ruben vorlegen → gemeinsam nächsten Schritt bestimmen

**Mindmap-Regel:** Claude Code aktualisiert die Mindmap nach jeder abgeschlossenen Phase und weist Ruben auf Entscheidungspunkte hin. Ruben entscheidet, Claude Code setzt um.

## Opus = Projekt-Kopf (Rollen-Hierarchie)

Opus ist die **oberste Instanz** in der Projekt-Hierarchie:
- Erstellt `projekt.md` (autoritatives Plandokument — Single Source of Truth)
- Definiert Phase I komplett: Issues, Akzeptanzkriterien, Testverfahren, Modellzuordnung
- Legt fest: WELCHES Modell setzt um UND WELCHES Modell die Umsetzung überprüft
- Entscheidet bei Architektur, Eskalationen, Versionierung

## Workflow-Phasen (pro Version / größere Iteration)

| Phase | Verantwortung | Inhalt |
|-------|--------------|--------|
| **I: Planung** | **Opus** | `projekt.md` erstellen/aktualisieren, Mindmap, Kanban-Issues, Akzeptanzkriterien, Testverfahren (WER testet WIE), Modellzuordnung pro Issue/Sub-Task |
| **II: Umsetzung** | **Sonnet (Orchestrator)** | Issue für Issue gemäß Opus-Plan. Orchestrator spawnt Subagenten (Implementer, Tester, Reviewer, Documenter, Deployer). Nach jedem Issue: Abgleich mit `projekt.md` — bei Abweichung Planner (Opus) spawnen |
| **III: Evaluation** | **Opus** | Gesamtprüfung: Projektziel gemäß `projekt.md` erfüllt? Alle Akzeptanzkriterien bestanden? |
| **IV: Abschluss** | **Opus** | Versionsnummer vergeben, Dokumentation finalisieren |

## Phase I Pflicht-Lieferungen (Opus — als Planner-Subagent)
1. `projekt.md` mit Architektur, DB-Schema, Phasenplan
2. Mindmap (`claude-projekt/mindmaps/`)
3. GitHub Issues im Kanban mit Akzeptanzkriterien (4 Pflichtbestandteile)
4. Pro Issue: Umsetzungsanleitung, Modellzuordnung, Testverfahren (inkl. welches Modell testet)

## Phase II — Sonnet als Orchestrator
- Sonnet spawnt Subagenten für jede Aufgabe
- Liest Opus-Plan aus `projekt.md`, delegiert an den passenden Subagenten
- Bei Opus-Aufgabe: Planner-Subagent (Opus) spawnen, NICHT selbst versuchen
