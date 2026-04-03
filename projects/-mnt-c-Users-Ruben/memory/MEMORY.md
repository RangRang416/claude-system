# Auto-Memory - Ruben's Workspace

## Feedback / Korrekturen
- [feedback_spawn_breakeven.md](feedback_spawn_breakeven.md) — Spawn-Breakeven VOR jedem Tester-Spawn prüfen, nicht Pipeline mechanisch anwenden

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
7. **claude-soul** - LIVE (Hetzner MCP-Server) — v2.8, Qdrant Memory-Kontinuität

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
- **Lokale claude-soul Kopie veraltet:** `/mnt/c/Users/Ruben/claude-soul/` kann veraltet sein → immer frischen Clone oder GitHub als Basis nutzen
- **Telegram Bot Token:** War öffentlich (Secret Scanning Alert #1), revoked + bereinigt (2026-03-22)

## Letzte Session (2026-04-03) — claude-system #22/#21 + Issues #19-#29

### claude-system: Regelwerk-Konsolidierung (Batch "Regelqualität")
- **#22:** MUSS/MUSS NICHT/SOLL/KANN-Schema in CLAUDE.md (Voll+Kompakt) — 15 MUSS, 6 MUSS NICHT, 13 SOLL. Planner definierte Schema (4 Stufen, max 15 MUSS, Anti-Inflation). Scout-Spawn → SOLL.
- **#21:** critic.md erstellt — Opus, unabhängig, kalt starten (DARF NICHT Planner-Kontext erhalten). Planner+Critic Bootstrap-Review durchgeführt (CHANGES_REQUESTED → gefixt).
- **projekt.md** für claude-system erstellt (war nicht vorhanden).
- **Kritische Fixes:** MUSS NICHT ≠ DARF NICHT (Unabhängigkeitsprinzip), Glob verboten für Critic, Klasse-C-Pipeline ergänzt um Critic⁴.
- **Commit steht aus** — alle Änderungen staged, nächste Session committen + pushen.
- **Offene Issues:** #19, #20, #23, #24, #25, #26, #27, #29 — Reihenfolge: #20→#23→#19→#24→#29→#25→#26→#27

### Neue Issues (2026-04-03)
- #20: Session-Start Orchestrator liest handover.md selbst
- #21: Critic-Agent (implementiert, Bootstrap-Review done)
- #22: MUSS/SOLL/KANN-Schema (implementiert, uncommitted)
- #23: Issue-Kommentare --comments Pflicht
- #24: Planner Effort-Level → SOLL max effort
- #25: Critic MUSS vor Review/Commit bei Architektur existieren
- #26: Orchestrator prüft Planner-Wirtschaftlichkeit bei mehreren Issues
- #27: Orchestrator MUSS Issues token-effizient eintragen/delegieren
- #28: Bootstrap-Review critic.md (erledigt)
- #29: planner.md why:-Felder im Ausgabeformat

## Letzte Session (2026-03-25) — claude-soul v2.8 + claude-system #16/#17/#18/#36

### claude-soul: Memory-Kontinuität implementiert + deployed (v2.8)
- **#35a–#35g:** Qdrant vector DB (Docker), @xenova/transformers (local ONNX embeddings), store_memory/recall_memories Tools, start_session mit recent_memories, memory-sanitizer.js (Prompt-Injection-Schutz)
- **#34:** Staleness-Hint wenn last_updated > 72h
- **#37:** Fehlermeldung "Proposal nicht gefunden oder abgelaufen" statt 404-Text
- **Kritische Fixes:** Qdrant braucht UUID/Integer-IDs (nicht beliebige Strings), `await isHealthy()` statt `!isHealthy()`
- **start_session score threshold:** 0 (nicht 0.3) damit Memories nicht rausgefiltert werden
- **#35f (Zeitboost):** Backlog, übersprungen

### claude-system: Planner-Workflow-Lücken geschlossen (#16/#17/#18/#36)
- **#16/#36:** Vor Planner-Spawn Pflichtschritte in CLAUDE.md: `gh issue view` + `projekt.md` lesen
- **#17:** why:-Pflichtfeld für alle Planner-Entscheidungen (CLAUDE.md + planner.md Template)
- **#18:** Review-Loop nach Planner-Spawn mit Freigabe-Schritt
- **#19 (offen):** "Orchestrator prüft Planner-Output nicht gegen Issue-Methodik" — noch nicht umgesetzt

### Offene Issues (nächste Session)
- claude-system #19: Explorer-Agent-Pflicht bei Technologie-Entscheidungen
- claude-soul #35f: Zeitboost für Memories (optional, Backlog)
- Telegram-Bot reaktivieren (läuft nicht, kein Systemd-Service)

## Letzte Session (2026-03-22) — claude-soul v2.4–v2.6 + Security-Fix

### claude-soul: 4 Issues abgeschlossen + deployed
- **#30:** may_propose Timing-Fix — registerMessage() vor handleRequest()
- **#31:** Rate-Limit update_profile — max 5/Session, isError bei Überschreitung
- **#32:** resume_session Tool — Zeitdelta, Hint aus soul-criteria.json, profile_delta In-Memory
- **#33:** System-Prompt Verhaltensregeln — Ton-Anpassung, Proaktivität (max 1x/Session), stiller Kontext

### claude-system: Security-Fix
- Telegram Bot Token war öffentlich (Secret Scanning Alert #1)
- Token revoked, 6 Dateien bereinigt (${TELEGRAM_BOT_TOKEN}), Alert geschlossen

## Ältere Sessions
→ Archiviert. Siehe Git-History der jeweiligen Repos.
- 2026-03-21: claude-system #10/#11/#7 abgeschlossen
- 2026-03-17: claude-soul v2.2/v2.3, claude-system #8/#9
- 2026-03-11: claude-soul V2 dynamische Soul (6 Issues, propose_update, confirm_proposal)
- 2026-03-10: claude-soul V1.0 abgeschlossen (6/6 Issues, MCP-Server, Telegram, Autostart)
- 2026-03-08: Vorgangs-Manager v1.5 (E-Mail-Import, 2FA, Dedup-Bug, Haiku statt Sonnet)
- 2026-03-04: Vorgangs-Manager #34 Eval-Set komplett (27/30 PDFs)
- 2026-03-01: Vorgangs-Manager v1.0 released, Workflow A/B/C validiert
- 2026-02-28: Documenter abgeschafft, Scout entfernt, Klassen A/B/C eingeführt
- 2026-02-26: Konsolidierung → claude-system Repo
- 2026-02-22–25: Agentic Workflow v0.1–v0.3 (Templates, Native Agenten, Token-Effizienz)
- vor 2026-02-22: Vorgangs-Manager Aufbau, KI-Kern, LIVE-Deployment
