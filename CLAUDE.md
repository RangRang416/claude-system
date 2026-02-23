# User Memory - Ruben's Global Preferences

## 📚 Comprehensive Documentation (Import)
@/mnt/c/Users/Ruben/.claude/memory.md

## 🔄 Agentic Workflow (Globale Arbeitsregeln)
@/mnt/c/Users/Ruben/.claude/CLAUDE.md

---

## 🎯 Quick Reference (Most Important)

### Server Access
- **SSH:** `ssh hetzner`
- **Server:** 46.224.220.236:2222, User: bernd
- **Key:** ~/.ssh/bernd_ed25519 (pre-configured)

### Secrets Location
- **Path:** `~/.claude/secrets/`
- **N8N API:** `~/.claude/secrets/n8n-api-key`

### Current Projects
1. **Soziotherapie App** - ✅ Live (praxis-olszewski.de/soziotherapie)
2. **N8N Email Analyzer** - 🔄 In Progress (/mnt/c/Users/Ruben/.claude/Hetzner-Server/n8n-email-analyzer)
3. **Vorgangs-Manager** - ✅ LIVE, KI-Kern aktiv (/mnt/c/Users/Ruben/.claude/vorgangs-manager)
4. **Agentic Workflow** - ✅ v1.0 PoC erfolgreich (/mnt/c/Users/Ruben/.claude/agentic-workflow)

### Telegram Bot
- **Bot:** @Hetznit_bot
- **Token:** 8218652700:AAFyez3gfj_z3GaLdxNN141159RD98wjUgw
- **Chat ID:** 6022997475

### GitHub Repositories ⚡
**Alle 12 lokalen Projekte haben GitHub-Remotes:**

| Repository | GitHub URL | Status |
|------------|-----------|--------|
| **HetznerMCP** | https://github.com/RangRang416/HetznerMCP.git | ✅ MCP-Server Code |
| **Hetzner-Server** | https://github.com/RangRang416/Hetzner-Server.git | ✅ Deployments & Docs |
| **soziotherapie_demo** | https://github.com/RangRang416/soziotherapie_demo.git | ✅ Produktiv-App |
| **n8n-email-analyzer** | https://github.com/RangRang416/n8n-email-analyzer.git | 🔄 In Entwicklung |
| **destatis-api** | https://github.com/RangRang416/destatis-mcp-server.git | ✅ MCP-Server |
| **wow-quest-optimizer** | https://github.com/RangRang416/wow-quest-optimizer.git | ✅ Aktiv (API-Integration) |
| **nike-laufen** | https://github.com/RangRang416/nike-laufen.git | ✅ Running Tracker ⚡ NEU |
| **kvk-kit-api** | https://github.com/RangRang416/kvk-kit-api.git | ✅ API-Projekt ⚡ NEU |
| **webseite-praxis** | https://github.com/RangRang416/webseite-praxis.git | ✅ Website-Entwürfe ⚡ NEU |
| **zettelkasten** | https://github.com/RangRang416/zettelkasten.git | ✅ Notiz-System ⚡ NEU |
| **claude-projekt** | https://github.com/RangRang416/claude-projekt.git | ✅ MCP-Tests ⚡ NEU |
| **claude-code-probleme** | https://github.com/RangRang416/claude-code-probleme.git | ✅ Troubleshooting ⚡ NEU |
| **vorgangs-manager** | https://github.com/RangRang416/vorgangs-manager.git | ✅ Vorgangs- & Archiv-App (LIVE) |
| **agentic-workflow** | https://github.com/RangRang416/agentic-workflow.git | ✅ Subagenten-Workflow PoC ⚡ NEU |
| **claude-root-config** | https://github.com/RangRang416/claude-root-config.git | ✅ Root-Config (private) ⚡ NEU |

**Wichtig:** Alle Repos können gepusht werden, immer VORHER fragen!

---

## ⚡ Working with Ruben

### Key Principles
- **Ruben = Project Manager** (NOT a developer)
- **Claude = Autonomous Developer** (make technical decisions independently)
- **Communication:** Clear, non-technical explanations only
- **Ask only:** Strategic decisions, credentials, business logic

### What NOT to ask
- ❌ Code implementation details
- ❌ Library/framework choices
- ❌ How to structure code
- ❌ Debugging approaches

### What TO ask
- ✅ Strategic architecture decisions
- ✅ Business logic clarification
- ✅ Missing credentials/API keys
- ✅ User testing feedback

---

## 🔧 Technical Standards

### Git Automation Rules ⚡

**AUTONOM ausführen (OHNE Rückfrage):**
```bash
✅ git add .                    # Dateien stagen
✅ git commit -m "..."          # Mit korrektem Format committen
✅ BACKLOG.md aktualisieren     # Projekt-Status dokumentieren
✅ Tests schreiben & ausführen  # Vor jedem Commit
✅ Code implementieren          # Features/Fixes
✅ gh issue view #XX            # Issue-Details lesen
✅ Branch erstellen             # feature/* oder fix/*
```

**MIT Rückfrage ausführen:**
```bash
❓ git push                     # Push zu Remote
❓ gh issue close #XX           # Issue schließen
❓ gh repo create               # Neues GitHub-Repo
❓ Branch löschen               # Nach Merge
❓ Deployment (Server)          # Production-Changes
```

**Workflow-Beispiel:**
```
User: "Implementiere Issue #42"

Claude (automatisch):
1. gh issue view 42
2. Code schreiben
3. Tests schreiben
4. git add .
5. git commit -m "feat: ... (Fixes #42)"
6. BACKLOG.md update

Claude (fragt): "Soll ich pushen?"
User: "Ja" → git push
```

---

### Git Commits Format
```
type: description

Context/details
- Bullet points for changes

Fixes #XX

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Commit-Typen:**
- `feat:` Neues Feature
- `fix:` Bugfix
- `docs:` Dokumentation
- `refactor:` Code-Refactoring
- `test:` Tests
- `chore:` Wartung/Cleanup

---

### Security
- Never commit secrets
- Use .env files (gitignored)
- Store credentials in ~/.claude/secrets/

### MCP Servers
- **mcp-n8n:** Only works with LOCAL n8n (localhost:5678)
- **Remote servers:** Use SSH + direct API calls

---

## 📝 Standard-Dokumentations-Workflow

**WICHTIG:** Dieser Workflow wird automatisch nach jeder wichtigen Änderung durchgeführt!

### Wann dokumentieren?
- ✅ Neue Features/Projekte implementiert
- ✅ System-Konfiguration geändert (Server, Auto-Updates, etc.)
- ✅ GitHub-Repos erstellt/aktualisiert
- ✅ Neue Tools/Services deployed
- ✅ Größere Bugfixes abgeschlossen

### Automatische Schritte:

#### 1. **CHANGELOG.md aktualisieren** (in relevantem Repo)
```markdown
## [YYYY-MM-DD] - Titel

### ✅ Durchgeführt
- Feature/Änderung 1
- Feature/Änderung 2

### 📝 Details
Technische Details...
```

#### 2. **CLAUDE.md "Recent Changes" updaten** (global)
```markdown
## 📝 Recent Changes (YYYY-MM-DD)

### Titel
- Änderung 1
- Änderung 2
```

#### 3. **PROJECT-OVERVIEW.md updaten**
- Mindmap erweitern (neue Projekte/Features)
- Aktivitäten-Log aktualisieren
- Fokus-Projekte anpassen
- Statistiken updaten

#### 4. **Git Commit & Push-Frage**
```bash
git add CHANGELOG.md PROJECT-OVERVIEW.md
git commit -m "docs: Update documentation (YYYY-MM-DD)

- CHANGELOG aktualisiert
- PROJECT-OVERVIEW erweitert

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

**Dann IMMER fragen:** "Soll ich zu GitHub pushen?"

### Visualisierung mit Mermaid Mindmap
**PROJECT-OVERVIEW.md** enthält Mermaid-Mindmap:
- Auf GitHub automatisch gerendert
- VS Code: "Markdown Preview Mermaid Support" Extension
- Online: https://mermaid.live

### Prinzip: "Wenn nicht dokumentiert, existiert es nicht"
Alle Projekte müssen:
- ✅ GitHub-Repo haben
- ✅ README.md mit Beschreibung
- ✅ In PROJECT-OVERVIEW.md aufgeführt sein
- ✅ In CLAUDE.md Repo-Liste erscheinen

---

## 📝 Recent Changes (2026-02-23)

### Scout-Agent + Root-Config portabel gemacht
- **Neuer Agent: Scout (Haiku)** — Codebase-Erkundung und Kontext-Vorfilterung
- **Erster Test:** Vorgangs-Manager erkundet — ~$0.01 statt ~$0.14 (93% Ersparnis)
- **Jetzt 7 Agenten:** Scout, Planner, Implementer, Tester, Reviewer, Documenter, Deployer
- **`/root/.claude/` als Git-Repo:** Agenten, Memory, Scripts, Doku portabel für 2. Computer
- **Neues Repo:** `claude-root-config` (private) — Whitelist-basierte .gitignore (Secrets ausgeschlossen)

### Vorherige: Agentic Workflow Feinschliff + Progressive Disclosure
- **Native Agenten:** `.claude/agents/` mit YAML-Frontmatter (6 Agenten)
- **Progressive Disclosure:** CLAUDE.md von 311→123 Zeilen (-60%), Details in `@docs/` ausgelagert
- **Dreischichtige Architektur:** Global (CLAUDE.md) → Projekt (./CLAUDE.md) → Agenten (.claude/agents/)

### Vorherige Änderungen (2026-02-22)

### Agentic Workflow: PoC erfolgreich + CLAUDE.md umgestellt
- **Subagenten-System:** 6 Rollen, Rechte-Matrix, Eskalationslogik
- **PoC am Vorgangs-Manager:** Issue #19-A/B/C, Review fing echten Bug, ~39% Token-Ersparnis
- **CLAUDE.md:** Sections 0-4 auf Subagenten-Workflow umgestellt
- **GitHub:** https://github.com/RangRang416/agentic-workflow

### Vorherige Änderungen (2026-02-20)

### Vorgangs-Manager: Phase I v1.0 abgeschlossen (Opus)
- **projekt.md komplett neu:** Phase I–IV Struktur gemäß CLAUDE.md Workflow
- **Issues #17, #18, #19** geplant mit Sub-Tasks, Akzeptanzkriterien, Modellzuordnung

### Vorherige Änderungen (2026-02-19)

### Vorgangs-Manager: KI-Prompt-Optimierung + DB-Bereinigung
- **Regel 1 verschärft:** Zuordnung nur bei exakt gleichem Absender + identischem Sachthema
- **Neue Regel 2:** Wohngeld ≠ Rente ≠ Steuern ≠ Sozialhilfe — NIE zusammenführen
- **Multi-Scan:** `$is_segment=true` → automatisch `konfidenz="niedrig"`
- **DB bereinigt:** Vorgang 3 (Wohngeld) sauber, Vorgang 16 "Steuern 2025" + 17 "Rente 2025" angelegt
- **Deployed + gepusht** — bereit für Ruben-Test

### Vorherige Änderungen (2026-02-18)
- Issue #14 Bugfix: Apache LANG=C → ASCII-sichere Dateinamen für Split-PDFs
- Haiku-Umstellung für OCR + Multi-Dokument-Erkennung

---

## 📝 Recent Changes (2026-02-15)

### Vorgangs-Manager: KI-Kern — Auto-Zuordnung + Lernfähigkeit
- **LIVE:** https://praxis-olszewski.de/vorgaenge
- **Auto-Zuordnung (Issue #10):** KI gibt `konfidenz` zurück (hoch/niedrig)
  - hoch + bekannter Vorgang → automatisch zuordnen, kein Confirm
  - hoch + kein Match → neuen Vorgang automatisch anlegen
  - niedrig/Duplikat → Bestätigungsseite (Nutzer entscheidet)
- **Reicherer KI-Kontext:** Beschreibung, letzte Aktivität, Dokument-Namen pro Vorgang
- **Pre-KI Kontrahent-Erkennung:** Regelbasiert vor API-Call, Treffer als VOR-ERKENNUNG
- **Lerneffekt (ki_feedback):** Nutzer-Korrekturen werden gespeichert und als LERNEFFEKTE in Prompt injiziert
- **Prompt gehärtet:** Erlaubte Werte strikt, 8 Regeln, Markdown-Stripping
- **Offenes Issue:** #8 (UI-Polishing)

### Vorherige Änderungen (2026-02-14)
- Thema-Feld, Querverbindungen, Vorgang-Ableiten, Duplikat-Erkennung
- Vorgänge zusammenführen (Issue #4), KI-Konsistenz (Issue #9)
- Deployment-Fix: SCP statt sed-Pipe, Backup erweitert (Issue #7)

### Vorherige Änderungen (2026-02-07)
- Server Security-Updates, Docker 29.2.1, Pre-Update-Backup
- Projekt-Workflow definiert, MEMORY.md eingerichtet

---

**Note:** Full detailed documentation available in imported memory.md
