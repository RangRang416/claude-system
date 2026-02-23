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
- **Globale Config:** `/root/.claude/CLAUDE.md` (Regeln, Git-Workflow, Repo-Liste)
- **Profil & Infra:** `/mnt/c/Users/Ruben/.claude/memory.md` (Server, Projekte, Credentials)
- **Projekt-Workflow:** `projekt-workflow.md` in diesem Ordner (PFLICHT bei neuen Projekten)
- **Detail-Notizen:** `server-maintenance.md` in diesem Ordner

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

## Letzte Session (2026-02-23) — Scout-Agent + Agentic Workflow Erweiterung
- **Neuer Agent: Scout (Haiku)** — 7. Rolle im Subagenten-System
  - Codebase-Erkundung und Kontext-Vorfilterung für den Orchestrator
  - Darf NUR lesen/suchen (Read, Glob, Grep, WebFetch, WebSearch)
  - Liefert max 30 Zeilen Zusammenfassung statt roher Dateiinhalte
  - **Erster Test am Vorgangs-Manager:** 45.800 Token (Haiku), 11 Tool-Aufrufe, 29 Sek, ~$0.01
  - **Token-Ersparnis:** ~93% vs. Sonnet-Selbstlesen (~$0.01 statt ~$0.14)
- **Erstellt in beiden Orten:**
  - `.claude/agents/scout.md` (nativer Agent)
  - `agentic-workflow/templates/scout.md` (Doku-Template mit Platzhaltern + Szenarien)
- **CLAUDE.md Rechte-Matrix erweitert:** Neue Spalte "Lesen/Suchen", Scout-Zeile hinzugefügt
- **README.md (agentic-workflow):** Scout in Agenten-Tabelle, Reviewer auf "dynamisch" korrigiert
- **Gepusht:** Claude-Projekte (`cd2e7f4`) + agentic-workflow (`574d485`)

## Vorherige Session (2026-02-23) — Agentic Workflow: Feinschliff + Progressive Disclosure
- **Opus-Pflicht-Trigger ergänzt:** Refactoring 3+ Dateien → Opus (Sonnet verliert Import-Bezüge)
- **Reviewer-Logik optimiert:** Standard-Code mit bestandenem Test → Haiku statt Sonnet (spart ~2.500 Tokens/Issue)
- **Documenter-Template verschärft:** "Ausführliche Zusammenfassung, KEINE Ein-Satz-Updates" (Haiku-Tendenz zu minimal)
- **Native Agenten erstellt:** `.claude/agents/` mit YAML-Frontmatter (6 Agenten: planner, implementer, tester, reviewer, documenter, deployer)
  - Jeder Agent hat explizite `tools`/`disallowedTools` = Rechte-Matrix auf Code-Ebene
- **Progressive Disclosure:** CLAUDE.md von 311→123 Zeilen (-60%)
  - Details in `@docs/` ausgelagert (nur on-demand geladen)
  - `docs/projekt-start.md`, `docs/eskalation.md`, `docs/rollback.md`, `docs/projektabschluss.md`
  - Spart ~190 Zeilen Kontext pro API-Call
- **Dreischichtige Architektur:** Global (CLAUDE.md) → Projekt (./CLAUDE.md) → Agenten (.claude/agents/)

## Letzte Session (2026-02-22) — Agentic Workflow PoC + CLAUDE.md Integration
- **Agentic Workflow Projekt:** Subagenten-System für token-sparsameren Workflow
- **6 Templates erstellt:** Planner (Opus), Implementer, Tester, Reviewer, Documenter, Deployer
- **PoC erfolgreich:** Issue #19-A/B/C am Vorgangs-Manager getestet
  - 7 Subagenten-Aufrufe, Review hat echten Bug (user_aktion NOT NULL) gefangen
  - Token-Ersparnis: ~39% gemessen, ~53% geschätzt mit Sonnet-Orchestrator
- **CLAUDE.md komplett umgestellt:** Sections 0-4 auf Subagenten-Workflow
  - Manuelle Modellwechsel entfallen, handover.md nur noch bei Session-Ende
  - Rechte-Matrix: nur Orchestrator committet/pusht, nur Deployer deployt
- **GitHub:** https://github.com/RangRang416/agentic-workflow (3 Issues, alle closed)

## Letzte Session (2026-02-20) — Phase I v1.0 abgeschlossen (Opus)
- **projekt.md komplett neu:** Phase I–IV Struktur, Übersicht für Ruben, technische Referenz
- **Architekturentscheidung #8:** Zwei Typ-Felder (vorgaenge.typ = Institution, dokumente.dokument_typ = Schriftstück)
- **CLAUDE.md erweitert:** Workflow-Phasen, Rollen, Test-Nachweis, Eskalation, Haiku-Rolle
- **Issues #17, #18, #19** mit Sub-Tasks, Akzeptanzkriterien, Modellzuordnung, Abschluss-Flows
- **handover.md** für Phase II (Sonnet) erstellt
- **Nächster Schritt:** Sonnet startet #17 (DB-Migration + UI, dann Opus für KI-Prompt)

## Letzte Session (2026-02-18) — Issue #14 Bugfix
- **Root Cause Issue #14:** LANG=C auf Apache → qpdf erstellt Split-PDFs ohne UTF-8-Zeichen im Pfad,
  aber file_exists() prüfte den Pfad MIT Umlauten → mismatch → Fallback kopierte immer die ganze PDF
- **Fix:** ASCII-sichere Dateinamen für alle Shell-Operationen (preg_replace)
- **Deployed + Testdaten bereinigt** — bereit zum erneuten Test

## Letzte Session (2026-02-19) — Git-Setup für .claude + Session-Workflow
- **Git eingerichtet** in `/mnt/c/Users/Ruben/.claude`
- **Remote:** https://github.com/RangRang416/Claude-Projekte (Branch: main)
- **.gitignore:** Secrets, Projekt-Repos (eigene Remotes), temporäre Claude-Dateien ausgeschlossen
- **Session-Ende-Befehl** in CLAUDE.md auf korrekten Pfad geändert
- **Push erfolgreich** — ab sofort wird jede Session versioniert

## Letzte Session (2026-02-19) — Abend: Issue #15 + #16 + DB-Fix

- **Issue #15 (Multiscan):** Sonnet-Tasks A+B implementiert — Auto-Zuordnung sicherer Segmente, Vorgang-Dropdown
- **Issue #16 (Löschen):** CSRF-Token fehlte in index.php → eine Zeile ergänzt + deployed
- **DB readonly-Bug:** vorgaenge.db-shm/.db-wal gehörten bernd → chown www-data behoben
- **WAL-Warnung:** Direktzugriff auf DB per SSH (als bernd) → immer danach Rechte prüfen!
- **Offenes Issue:** KI erkennt Typ + Thema nicht korrekt → Opus-Eskalation empfohlen (ki_feedback + Prompt)
- **handover.md aktualisiert** — enthält alle Details für morgen
- **Noch nicht getestet:** Tests 3, 4, 5 (Multi-Scan Zuordnung/Neuer Vorgang/Auto)

## Letzte Session (2026-02-19) — KI-Prompt-Optimierung abgeschlossen
- **KI-Prompt verschärft (import.php):**
  - Regel 1: NUR bei exakt gleichem Absender + identischem Sachthema zuordnen (Negativbeispiele im Prompt)
  - Neue Regel 2: Thementrennung — Wohngeld ≠ Rente ≠ Steuern ≠ Sozialhilfe (IMMER eigenständig)
  - Multi-Scan-Segmente: `$is_segment=true` → automatisch `konfidenz="niedrig"`
- **DB-Bereinigung auf Server:**
  - Vorgang 3 (Wohngeld) bereinigt
  - Vorgang 16 "Steuern 2025" angelegt
  - Vorgang 17 "Rente 2025" angelegt, Dokumente 27+28 dorthin verschoben
- **Deployed, committet, getestet, gepusht** — alles sauber ✅
- **Offene Issues:** keine bekannten — Projekt wartet auf Ruben-Test im Browser

## Letzte Session (2026-02-16)
- **Issue #4 komplett implementiert (alle 4 Teilbereiche):**
  - A: Vorgang-Erkennung — Relevanz-Ranking (Top 15 statt 60, Keyword-Score + Bonus)
  - B: Mixed-PDF — seitenweise Extraktion (pdftotext pro Seite, Scan-Seiten → Vision OCR)
  - C: Dokumentnamen — Original-Dateiname + PDF-Titel als Kontext, Regel #10 mit Beispielen
  - D: Schritte-Tracking — DB-Tabelle `schritte`, KI generiert/hakt ab, Checkliste-UI
- **Dashboard:** KPIs als kompakte Liste statt Grid-Karten
- **Deployed** auf Server (alle 5 Dateien), GitHub gepusht
- **Offene Issues:** keine (Issue #4 sollte geschlossen werden nach Test)

## Letzte Session (2026-02-15) — Abend
- **UI-Polishing (Issue #8):** style.css, kompaktes Dashboard, echte Vorgangsliste
- **DOCX-Support + Bild-PDF-Fallback:** ZipArchive für DOCX, pdftoppm für Scan-PDFs
- **Bugfix Abbrechen:** Import-Session wird jetzt korrekt gelöscht (?action=reset)
- **KI-PoC Wohngeldantrag:** Mixed-PDFs = Schwachstelle, Vorgang-Erkennung unzuverlässig
- **Issue #4 wieder geöffnet:** Vorhandene Vorgänge nicht erkannt → vor E-Mail-Import lösen
- **E-Mail-Import zurückgestellt:** erst KI-Genauigkeit verbessern (Workflow-Entscheidung)
- **Offenes Issue:** nur #4 (Vorgänge zusammenführen / Mixed-PDF)

## Letzte Session (2026-02-15) — Vormittag
- **Vorgangs-Manager: KI-Kern — Auto-Zuordnung + Lernfähigkeit**
  - Issue #10: Auto-Zuordnung — KI gibt konfidenz zurück (hoch/niedrig)
  - Reicherer Kontext, Pre-KI Kontrahent-Erkennung, ki_feedback Tabelle
  - Getestet: Burdenski→hoch+ID1, anonyme Rechnung→niedrig, AOK Q4→hoch+ID2

## Vorgangs-Manager Architektur (KI-Flow)
```
Upload/Text → detect_kontrahenten_in_text() → Claude Haiku API
                                                   ↓
                                    Prompt enthält:
                                    - VOR-ERKENNUNG (regelbasiert)
                                    - LERNEFFEKTE (ki_feedback)
                                    - BESTEHENDE VORGÄNGE (mit Details)
                                    - BEKANNTE Themen/Kontrahenten/Tags
                                                   ↓
                                    konfidenz=hoch → Auto-Zuordnung
                                    konfidenz=niedrig → Confirm-Seite
                                                          ↓
                                                   Korrektur? → ki_feedback
```

## Session (2026-02-14)
- Thema + Querverbindungen + Duplikat-Erkennung + Vorgang-Ableiten
- Vorgänge zusammenführen (Issue #4)
- KI-Konsistenz (Issue #9): get_known_values(), Autocomplete datalists
- Prompt-Engineering: Werte gehärtet, Markdown-Stripping
- Deployment-Fix: SCP statt `sed | ssh "cat >"` (0-Byte-Problem)
- GitHub-Workflow: Issues mit in-progress Label, Fixes #N Auto-Close
- Backup: vorgaenge.db + uploads in pre-update-backup.sh (Issue #7)

## Session (2026-02-12)
- **Vorgangs-Manager Phase 1 vollständig** (Issues #1, #2, #3 + Deployment)
  - Issue #1: Grundgerüst (Login, DB-Schema, Dashboard)
  - Issue #2: Vorgänge CRUD (Liste, Formular, Detail, Status)
  - Issue #3: Aktivitäten-Timeline + Dokument-Upload (Drag&Drop, PDF-Extraktion)
  - LIVE: https://praxis-olszewski.de/vorgaenge (User: ruben / vorgaenge2026)
  - Server: /var/www/vorgaenge/app/, poppler-utils installiert
- PHP CLI lokal installiert (php8.1-cli + php8.1-sqlite3 in WSL)

## Session (2026-02-11)
- Vorgangs-Manager Phase 0: Planung, Repo, Mindmap, PLAN.md
- OCR: Acrobat DC lokal, kein Tesseract

## Session (2026-02-07)
- Server Security-Updates, Docker 29.2.1, Kernel-Update
- Pre-Update-Backup eingerichtet, MEMORY.md erstmals befüllt
- Projekt-Workflow definiert (projekt-workflow.md)
- Email-Analyzer aufgeteilt (Triage vs. Archiv)
