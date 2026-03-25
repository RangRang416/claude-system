# CHANGELOG - claude-system

## [2026-03-25] — Planner-Spawn Workflow erweitert (#16/#17/#18/#36)

### Geändert
- `CLAUDE.md`: Vor Planner-Spawn Pflichtschritte: `gh issue view` (vollständige Issues + Kommentare) + `projekt.md` lesen
- `CLAUDE.md`: Review-Loop nach Planner-Spawn mit explizitem Freigabe-Schritt (KEINE Zusammenfassung)
- `CLAUDE.md`: Planner-Output why:-Pflichtfeld dokumentiert
- `docs/templates/planner.md`: why:-Pflichtfeld in Liefere-Abschnitt + Output-Format erweitert

## [2026-03-21] — #10 Smoke-Test nach Deploy eingeführt + #11 Spawn-Breakeven

### Hinzugefügt (#10)
- `CLAUDE.md`: Smoke-Test-nach-Deploy-Regel (PFLICHT bei B/C, optional A/A+)
- Definition of Done: 5. Punkt "Smoke-Test nach Deploy" ergänzt
- Deployer-Rechte-Matrix: `smoke²`-Spalte hinzugefügt
- Planner-Pflicht: `smoke_test:`-Block in projekt.md pro Projekt

## [2026-03-21] — #11 Spawn-Breakeven als Pflichtschritt eingebaut

### Geändert
- `CLAUDE.md` (Vollversion): Expliziter 3-Zeilen-Block im Spawn-Breakeven-Abschnitt — "VOR jedem Tester/Reviewer-Spawn prüfen" mit Override-Logik
- `CLAUDE.md` (Kompaktversion): Spawn-Breakeven-Kurzregel in Abschnitt 3 eingefügt

## [2026-02-28] — Scout-Agent entfernt

### Entfernt
- `agents/scout.md` — Scout-Subagent abgeschafft (18-20k Token Overhead pro Spawn)
- Scout aus Rechte-Matrix, Tool-Restriktionen und Kommunikationsbeispielen in CLAUDE.md

### Geändert
- Session-Start (Sektion 0): Orchestrator liest `handover.md` und `projekt.md` direkt (~500 Token statt ~20.000)
- Schritte in Sektion 0: von 6 auf 5 reduziert
- Documenter-Scope: Negativliste ergänzt (CLAUDE.md, projekt.md, Workflow-Docs, MEMORY.md = Implementer/Planner)

### Hinzugefügt
- `docs/projekt-start.md`: Sektion "Bestehendes Projekt übernehmen" mit 8-Schritte-Checkliste

## [2026-02-27] - Agent-Definitionen konsolidiert und standardisiert

### ✅ Durchgeführt
- Issue #3: scout.md vollständig überarbeitet — Zwei-Modi-System (Status-Check <2k / Datei-Erkundung <8k), Token-Budgets, JSON-Output, RETRIEVAL-Grundregel, Tool-Restriktionen (kein Glob/Grep/Bash)
- Issue #4: planner.md gefixt — exploratives Scanning entfernt, JSON-Rückgabe-Format definiert, Kein-Prosa-Regel eingeführt
- Issue #5: tester.md, reviewer.md, implementer.md, deployer.md, documenter.md — JSON-Output in alle ergänzt, Kein-Prosa-Regel, deployer: PFLICHT-Freigabe durch Ruben als harte Regel
- Issues #1 & #2 geschlossen — Session-Start-Ablauf und Orchestrator-Workflow operativ, nächster Test beim Session-Start
- Planner-Analyse durchgeführt: alle 8 Agent-Definitionen systematisch gegen CLAUDE.md v2026-02-25 geprüft, Konsistenzlücken identifiziert und behoben

### 📝 Betroffene Dateien
- `/root/.claude/docs/templates/scout.md` (komplett rewritten)
- `/root/.claude/docs/templates/planner.md` (behoben)
- `/root/.claude/docs/templates/tester.md` (JSON-Rückgabe)
- `/root/.claude/docs/templates/reviewer.md` (JSON-Rückgabe)
- `/root/.claude/docs/templates/implementer.md` (JSON-Rückgabe)
- `/root/.claude/docs/templates/deployer.md` (JSON-Rückgabe + PFLICHT-Freigabe)
- `/root/.claude/docs/templates/documenter.md` (Prosa-Regel)

### 🎯 Erfolgskriterien
- Alle Agent-Templates sind konform mit CLAUDE.md Abschnitt 3 (Subagenten-Workflow)
- JSON-Output-Format einheitlich (status, files_touched, result, blockers)
- Token-Budgets explizit definiert und durchgesetzt
- Tool-Restriktionen dokumentiert (Scout: kein Glob, Planner: nur benannte Dateien, Documenter: 1.500 Cap)

## [2026-02-26] - Konsolidierung zu claude-system

### ✅ Durchgeführt
- Neues GitHub-Repo `claude-system` erstellt (https://github.com/RangRang416/claude-system)
- CLAUDE.md auf Version 2026-02-25 aktualisiert: agentic workflow rules, Session-Start-Ablauf, handover.md Pointer-Index
- `docs/` Ordner angelegt mit 4 Workflow-Dokumenten: eskalation.md, projekt-start.md, projektabschluss.md, rollback.md
- `docs/templates/` angelegt mit 8 Agent-Templates (Orchestrator, Scout, Planner, Implementer, Tester, Reviewer, Documenter, Deployer)
- `.gitignore` aktualisiert: docs/, CHANGELOG.md, README.md zur Whitelist hinzugefügt
- Remote-URL von `claude-root-config` zu `claude-system` gewechselt
- README.md mit Setup-Anleitung erstellt
- 3 alte Repos archiviert: `claude-root-config`, `Claude-Projekte`, `agentic-workflow`
- 2 Issues aus agentic-workflow nach claude-system übertragen (#1 Orchestrator-Workflow, #2 Token-Budget)
- MEMORY.md aktualisiert mit aktuellen Projektständen und Workflow-Details

### 📝 Neue Struktur
```
/root/.claude/
├── CLAUDE.md          ← Globale Regeln (Stand: 2026-02-25)
├── agents/            ← Native Agent-Definitionen (7 Agenten)
├── docs/              ← NEU: Workflow-Docs + Templates
│   ├── eskalation.md
│   ├── projekt-start.md
│   ├── projektabschluss.md
│   ├── rollback.md
│   └── templates/     ← 8 Agent-Templates
├── memory/            ← Auto-Memory + MEMORY.md
├── scripts/           ← Utility Scripts
└── secrets/           ← Credentials (gitignored)
```

### 🗃️ Archivierte Repos
- `claude-root-config` → archiviert (Funktionalität in claude-system)
- `Claude-Projekte` → archiviert (Docs in claude-system/docs/)
- `agentic-workflow` → archiviert (Agenten + Templates in claude-system)

### 🎯 Warum diese Änderung?
Alle Agenten, Dokumentationen und Globalen Regeln sind jetzt in **einem** Repo zentralisiert. Das reduziert Komplexität, verbessert Nachverfolgbarkeit (1 Git-History statt 3) und macht Session-Start einfacher (nur 1 `.claude` zum Klonen). Ruben kann die gesamte Infrastruktur auf einem neuen Computer mit `git clone` aufsetzen.
