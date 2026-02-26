# CHANGELOG - claude-system

## [2026-02-26] - Konsolidierung zu claude-system

### ✅ Durchgeführt
- Repo umbenannt: `claude-root-config` → `claude-system` (neues Remote-URL)
- CLAUDE.md auf Version 2026-02-25 aktualisiert (von Claude-Projekte übernommen)
- `docs/` Ordner angelegt mit 4 Workflow-Docs (eskalation, projekt-start, projektabschluss, rollback)
- `docs/templates/` angelegt mit 8 Agent-Templates (von agentic-workflow übernommen)
- Alte Repos archiviert: `claude-root-config`, `Claude-Projekte`, `agentic-workflow`

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
├── memory/            ← Auto-Memory
├── scripts/           ← Utility Scripts
└── secrets/           ← Credentials (gitignored)
```

### 🗃️ Archivierte Repos
- `claude-root-config` → archiviert
- `Claude-Projekte` → archiviert
- `agentic-workflow` → archiviert
