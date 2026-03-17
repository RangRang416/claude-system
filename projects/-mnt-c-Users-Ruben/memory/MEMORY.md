# Auto-Memory - Ruben's Workspace

## Rubens Arbeitsweise (DAUERHAFT)

**Bash-Commands / Implementierungen / Deployments:** Ohne Rückfrage durchführen. Ruben will keinen Bestätigungsdialog für einzelne Tool-Calls.

**Rückfragen NUR bei:**
- Architekturentscheidungen (neue DB-Tabellen, Tech-Stack-Änderungen)
- Blockern (fehlende Credentials, unklare Anforderungen)
- Strategischen Weichenstellungen (Versionierung, Issue-Priorisierung)
- Push zu Remote (einmalige Bestätigung pro Session reicht)

---

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

## Letzte Session (2026-03-17) — claude-soul v2.2/v2.3 + Workflow-Updates

### claude-soul: 6 Issues abgeschlossen + deployed
- **#22/#23:** System-Prompt neu strukturiert, 5 neue Regeln (rules.json), has_entries Rule-Typ, current_time in get_guidance, memory_layers-Doku
- **#21:** start_session ersetzt read_profile + get_guidance (1 statt 2 Round-Trips)
- **#24:** MIN_MESSAGES_BEFORE_PROPOSAL 4→2 (may_propose früher true)
- **Bugfix:** markdown-generator.js `p.id` → `p.proposal_id` (Proposal-IDs waren "?")
- **profile.md** manuell regeneriert nach markdown-generator-Fix
- **Lokale Kopie veraltet:** `/mnt/c/Users/Ruben/claude-migration/projektdoku/PROJEKT_HETZNER_CLAUDE/mcp-soul/` ist NICHT aktuell — immer `/tmp/claude-soul-work` (frischer Clone) oder direkt GitHub als Basis nutzen
- **System-Prompt Claude Desktop:** `start_session` statt read_profile + get_guidance

### claude-system: 3 Workflow-Lücken geschlossen (#8, #9, #10)
- **#8:** Tester/Reviewer dürfen dasselbe Modell sein (Klarstellung)
- **#9:** Orchestrator-Lösungsverbot — darf Probleme beschreiben, keine Architektur-Lösungen vorschlagen (Ausnahme: Klasse A/A+)
- **#10 (offen):** Workflow-Lücke: kein Integrations-Test nach Deploy

### Offene Issues (nächste Session)
- claude-system #10: Integrations-Test nach Deploy (Planner nötig)
- claude-system #7: Überprüfung Arbeitsprozess Claude-Coder

### Lessons Learned
- Lokale mcp-soul Dateien sind veraltet → immer frischen Clone verwenden
- Cross-component Bugs (Feldnamen-Mismatch zwischen Dateien) fallen erst in Phase III auf
- tool_search 2× bei Session-Start: WONTFIX (MCP-Client-Verhalten, nicht server-seitig lösbar)

## Letzte Session (2026-03-11) — claude-soul V2 dynamische Soul
- **6 Sub-Issues implementiert + deployed** (#7 → #8-#13), alle Tests bestanden
- **Neue Tools:** propose_update, confirm_proposal, soul-criteria.json, session-tracker.js
- **Commits:** 7 Commits auf RangRang416/claude-soul main

## Ältere Sessions
→ Archiviert. Siehe Git-History der jeweiligen Repos.
- 2026-03-10: claude-soul V1.0 abgeschlossen (6/6 Issues, MCP-Server, Telegram, Autostart)
- 2026-03-08: Vorgangs-Manager v1.5 (E-Mail-Import, 2FA, Dedup-Bug, Haiku statt Sonnet)
- 2026-03-04: Vorgangs-Manager #34 Eval-Set komplett (27/30 PDFs)
- 2026-03-01: Vorgangs-Manager v1.0 released, Workflow A/B/C validiert
- 2026-02-28: Documenter abgeschafft, Scout entfernt, Klassen A/B/C eingeführt
- 2026-02-26: Konsolidierung → claude-system Repo
- 2026-02-22–25: Agentic Workflow v0.1–v0.3 (Templates, Native Agenten, Token-Effizienz)
- vor 2026-02-22: Vorgangs-Manager Aufbau, KI-Kern, LIVE-Deployment
