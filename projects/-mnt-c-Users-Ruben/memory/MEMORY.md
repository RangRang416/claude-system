# Auto-Memory - Ruben's Workspace

## PFLICHT-WORKFLOW - JEDE SESSION (NICHT OPTIONAL)

**Diese Schritte werden UNAUFGEFORDERT ausgeführt. Ruben muss NICHT daran erinnern.**

### Bei neuem Projekt / größerer Aufgabe:
→ **ERST `projekt-workflow.md` lesen und befolgen.** Nie direkt coden.
→ Planen → Issues/Tasks → Schritt für Schritt → Testen → Dokumentieren

### Bei jeder inhaltlichen Änderung (Server, Code, Config):
1. **CHANGELOG.md** im betroffenen Repo aktualisieren
2. **CLAUDE.md** Recent Changes aktualisieren (`/root/.claude/CLAUDE.md`)
3. **PROJECT-OVERVIEW.md** aktualisieren (wenn relevant)
4. `git add` + `git commit` (automatisch)
5. **Fragen:** "Soll ich pushen?"

### Am Ende jeder Session:
1. **Diese MEMORY.md aktualisieren** (Letzte Session, Server-Status, neue Erkenntnisse)
2. **Detail-Dateien** in diesem memory/-Ordner ergänzen falls nötig

### Warum das wichtig ist:
Ruben ist Projekt-Manager, kein Entwickler. Dokumentation = Existenzbeweis.
Ohne Dokumentation weiß die nächste Session nichts. Ruben hat das MEHRFACH
angesprochen. Es ist wie die Einkaufstasche - selbstverständlich mitzunehmen.

---

## Wichtigste Referenzen
- **Globale Config:** `/root/.claude/CLAUDE.md` (Agentic Workflow Regeln, Agenten-Matrix)
- **Workflow-Docs:** `/root/.claude/docs/` (eskalation, projekt-start, projektabschluss, rollback)
- **Agent-Templates:** `/root/.claude/docs/templates/` (8 Templates)
- **Profil & Infra:** `/mnt/c/Users/Ruben/.claude/memory.md` (Server, Projekte, Credentials — extern)
- **Projekt-Workflow:** `projekt-workflow.md` in diesem Ordner (PFLICHT bei neuen Projekten)
- **Detail-Notizen:** `server-maintenance.md` in diesem Ordner

## System-Repos (Stand 2026-02-26)
- **claude-system** — https://github.com/RangRang416/claude-system (Haupt-System-Config, AKTIV)
  - Enthält: CLAUDE.md, agents/, docs/, docs/templates/, memory/, scripts/
  - Ersetzt: claude-root-config, Claude-Projekte, agentic-workflow (archiviert)
- **claude-root-config** — https://github.com/RangRang416/claude-root-config (ARCHIVIERT)
- **agentic-workflow** — https://github.com/RangRang416/agentic-workflow (ARCHIVIERT)

## Server-Status (Hetzner)
- **IP:** 46.224.220.236:2222, User: bernd, `ssh hetzner`
- **Kernel:** 6.8.0-100-generic (aktualisiert 2026-02-07)
- **Docker:** 29.2.1 (aktualisiert 2026-02-07)
- **Laufende Container:** n8n-email-analyzer, nginx-proxy-manager
- **Auto-Updates:** unattended-upgrades (Security), Sonntag 04:00 (alle)
- **Pre-Update-Backup:** Eingerichtet (apt-Hook + Cron), sichert DBs + n8n-Volume

## Aktive Projekte
1. **Soziotherapie App** - LIVE (praxis-olszewski.de/soziotherapie)
2. **N8N Email-Analyzer** - In Entwicklung (Posteo + Claude AI fehlt)
3. **Vorgangs-Manager** - LIVE (praxis-olszewski.de/vorgaenge) — KI-Kern fertig, Auto-Zuordnung aktiv
4. **WoW Quest Optimizer** - Aktiv
5. **Nike Laufen** - LIVE
6. **Agentic Workflow** - v1.0 PoC ERFOLGREICH (https://github.com/RangRang416/agentic-workflow)

## Bekannte Probleme / Hinweise
- Windows-Zeilenumbrüche (CR/LF) bei SCP-Uploads → `sed -i 's/\r//' datei` nötig
- Docker-Updates kommen NICHT aus Ubuntu-Repos → nicht von unattended-upgrades erfasst
- **DEPLOY via `sed | ssh "cat >"` ist UNZUVERLÄSSIG** → Datei wird manchmal 0 Bytes!
  → **Immer SCP verwenden:** `scp -P 2222 -i ~/.ssh/bernd_ed25519 datei bernd@46.224.220.236:/tmp/` → dann `sed -i 's/\r//'` + `cp` auf dem Server
- **SQLite WAL-Dateien:** Nach Direktzugriff auf DB als bernd → `chown www-data:www-data data/vorgaenge.db-shm data/vorgaenge.db-wal`
  → Sonst: "attempt to write a readonly database" → HTTP 500 bei ALLEN Schreiboperationen
- **Apache läuft mit LANG=C (POSIX)!** → UTF-8 in Shell-Befehlen oder Dateipfaden NICHT verwenden!
  → Alle Pfade für shell_exec/qpdf/system-Calls müssen ASCII-sicher sein
  → Bug: qpdf schrieb Datei ohne ä/ö/ü, PHP's file_exists() suchte MIT → nie gefunden

## Letzte Session (2026-02-26) — Konsolidierung zu claude-system
- **Neues Repo:** `claude-system` (https://github.com/RangRang416/claude-system)
- **Struktur:** CLAUDE.md (agentic workflow), agents/ (7), docs/ (4 Docs + 8 Templates)
- **CLAUDE.md:** Jetzt die agentic workflow Regeln direkt, `@docs/` Referenzen lösen gegen `/root/.claude/docs/` auf
- **Remote-URL** von `claude-root-config` auf `claude-system` umgestellt
- **Archiviert:** claude-root-config, Claude-Projekte, agentic-workflow Repos
- **Wichtig:** Die alte `/root/.claude/CLAUDE.md` (Wrapper mit memory-imports) ist ersetzt — Profil-Info kommt jetzt aus dieser MEMORY.md

## Letzte Session (2026-02-25) — Token-Effizienz + Workflow-Architektur
- **Token-Effizienz-Overhaul:**
  - Scout: Zwei-Modi (Status-Check <2k / Datei-Erkundung <8k), JSON-Output, kein Repo-Scan
  - handover.md → Pointer-Index (~200 Token, ~10 Zeilen, keine Prosa)
  - JSON-Payloads für alle Subagenten (keine Prosa-Berichte)
  - Tool-Restriktionen: Scout kein Glob/WebSearch, Planner nur benannte Dateien, Documenter Cap 1.500
  - Archivierungs-Logik: projekt.md/backlog.md > 200 Zeilen → archive_YYYY-MM.md
- **Session-Start-Ablauf neu definiert:**
  1. Orchestrator: `gh issue list` (selbst, 1 Befehl)
  2. Scout (Haiku): handover.md lesen → JSON
  3. Orchestrator: kombiniert beides → erkennt neue Issues
  4. Neue Issues → Empfehlung an Ruben → Ruben entscheidet → IMMER Planner (Opus)
  5. Ruben informieren → Loslegen
- **Phase-III-Rückfluss:** Ruben erstellt GitHub Issues beim Praxistest → nächste Session: Orchestrator gibt Empfehlung (Kernfunktion/Nice-to-have), Ruben entscheidet, Planner ordnet ein
- **Neue Regel:** Orchestrator ordnet KEINE neuen Issues selbst ein — immer Planner
- **Absturz-Sicherheit:** handover.md wird nach JEDEM Issue aktualisiert, nicht nur am Session-Ende
- **6 Commits, 2 Repos gepusht** (claude-root-config bis `2f44a00`, agentic-workflow `d69d6b0`)

## Agentic Workflow Evolution (Zusammenfassung 2026-02-22 bis 2026-02-25)
- **v0.1 (02-22):** 6 Templates, PoC erfolgreich, ~39% Token-Ersparnis gemessen
- **v0.2 (02-23):** Native Agenten (.claude/agents/), Progressive Disclosure, Scout als 7. Agent
- **v0.3 (02-25):** Token-Effizienz, Phase-III-Rückfluss, Planner-Pflicht, Absturz-Sicherheit

## Vorgangs-Manager (Zusammenfassung bis 2026-02-20)
- **LIVE:** https://praxis-olszewski.de/vorgaenge
- **KI-Kern:** Auto-Zuordnung, Lernfähigkeit (ki_feedback), konfidenz hoch/niedrig
- **Phase I v1.0 abgeschlossen:** Issues #17-#19 geplant (DB-Migration, UI, KI-Prompt)
- **Bekannte Issues:** Apache LANG=C → ASCII-sichere Pfade, SQLite WAL-Rechte nach SSH-Zugriff

## Vorgangs-Manager Architektur (KI-Flow)
```
Upload/Text → detect_kontrahenten_in_text() → Claude Haiku API
  → Prompt: VOR-ERKENNUNG + LERNEFFEKTE + VORGÄNGE + BEKANNTE Werte
  → konfidenz=hoch → Auto-Zuordnung | konfidenz=niedrig → Confirm-Seite
  → Korrektur? → ki_feedback
```

## Ältere Sessions (vor 2026-02-22)
→ Details archiviert. Siehe Git-History der jeweiligen Repos.
- 02-19: Issues #15/#16, KI-Prompt-Optimierung, Git-Setup für .claude
- 02-18: Issue #14 Bugfix (LANG=C + ASCII-Pfade)
- 02-16: Issue #4 komplett (Vorgang-Erkennung, Mixed-PDF, Schritte-Tracking)
- 02-15: KI-Kern live, Auto-Zuordnung, UI-Polishing
- 02-14: Thema, Querverbindungen, Duplikat-Erkennung, Deployment-Fix
- 02-12: Vorgangs-Manager Phase 1 komplett, LIVE deployed
- 02-07: Server Security-Updates, Docker 29.2.1, Pre-Update-Backup
