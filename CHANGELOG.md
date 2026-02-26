# CHANGELOG - claude-system

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
