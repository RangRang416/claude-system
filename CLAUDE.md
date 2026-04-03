# Claude Code – Globale Arbeitsregeln (kompakt)

**Letzte Überarbeitung: 2026-04-02 — Issue #22: MUSS/SOLL/KANN-Marker eingefügt**
**Vollversion: /root/.claude/CLAUDE.md**

---

## 0. Session-Start

Sonnet ist Orchestrator. Beim Start:
1. `gh issue list --state open --json number,title` (1 Befehl)
2. Orchestrator liest `handover.md` selbst. **SOLL** Scout (Haiku) spawnen NUR wenn: kein handover.md ODER projekt.md-Kontext nötig.
3. Scout liefert JSON: `{"issue_current","issue_next","blockers","files_last","hint"}`
4. Neue Issues → Planner (Opus). Bereits geplante → Orchestrator arbeitet ab.
5. Ruben informieren, loslegen.

**MUSS NICHT** beim Start: Rekursive Repo-Scans (`gh api .../git/trees`, `ls -R`, Glob `**/*`). Nur gezielte Reads.

**Vor Planner-Spawn:**
- **MUSS** `gh issue view <NR> --comments` ausführen (vollständige Issue-Beschreibung inkl. Kommentare)
- **MUSS** `projekt.md` lesen — kein Planner-Spawn ohne diese Schritte

**Review-Loop nach Planner-Spawn:**
- **MUSS** Orchestrator prüft Planner-Output gegen die Issue-Anforderungen
- Erst nach Rubens Freigabe mit Implementierung beginnen

---

## 1. Issue-Klassifizierung

| Klasse | Kriterien | Pipeline |
|--------|-----------|----------|
| A Trivial | 1 Datei, kein neues Verhalten | Orchestrator direkt |
| A+ Multi-Trivial | 2-3 Dateien, nur Imports/CSS/Config | Impl(Haiku) → Test(Haiku) |
| B Standard | 2-4 Dateien mit Logik | Impl(Sonnet) → Test(Sonnet) |
| C Komplex | 5+ Dateien/Security/KI/DB | Planner → Impl → Test → Review |

**MUSS** Ein Issue nach dem anderen. Kein paralleles Arbeiten.

---

## 2. Test & Commit

- **MUSS** Test VOR jedem Commit (Tester-Subagent, kein Ruben-Browsertest in Phase II)
- **MUSS** Push nur nach bestandenem Test + Ruben-Freigabe
- **MUSS** Smoke-Test nach Deploy (Klasse B/C): Deployer führt 1-3 echte Befehle aus. Kein Spawn.
- CHANGELOG.md nach jedem Commit (Details: Vollversion)

---

## 3. Subagenten

Orchestrator spawnt aus `.claude/agents/`.

**MUSS** Spawn-Breakeven VOR jedem Spawn prüfen: Dateien bereits im Kontext UND Arbeit < 5k Token? → Orchestrator direkt, kein Spawn.

**MUSS** Impl/Reviewer dürfen NICHT dasselbe Modell sein.
**MUSS NICHT** Reviewer bei Klasse A/A+ spawnen.
**MUSS** Orchestrator-Lösungsverbot: Darf Probleme beschreiben, aber keine Architektur-Lösungen vorschlagen. Ausnahme: Klasse A/A+.
**SOLL** Keine Prosa zwischen Subagenten — nur JSON.

**Opus-Pflicht:** KI-Prompts, Regex, nicht reproduzierbare Fehler, Security, DB-Migration, Performance, Refactoring 3+ Dateien.

---

## 4. Eskalation

- **MUSS** Test NICHT bestanden → max 2 Runden Fix, dann Planner
- **MUSS** Review CHANGES_REQUESTED → max 2 Runden, dann Planner
- Unklare Anforderung → Ruben fragen (nicht raten)

Details: `docs/eskalation.md`

---

## 5. Dokumentation

- **MUSS** `projekt.md` → Planner schreibt und pflegt (Single Source of Truth)
- **MUSS** `handover.md` → nach jedem Issue + Session-Ende (Pointer-Format, max 10 Zeilen)
- **MUSS** why:-Feld bei jeder nicht-trivialen Planner-Entscheidung
- CHANGELOG.md, backlog.md → SOLL (Details: Vollversion)

Archivierung wenn > 200 Zeilen → erledigte Teile in `archive_YYYY-MM.md` verschieben (Details: Vollversion).

---

## 6. Rollback

Bei fehlgeschlagenem Deploy: `git revert` → neu deployen → Issue dokumentieren.
Details: `docs/rollback.md`

---

## 7. Projekt-Start & -Abschluss

Neues Projekt → Planner (Opus) spawnen → Phasen I/II/III definieren.
Details: `docs/projekt-start.md`, `docs/projektabschluss.md`

---

## 8. Session-Ende

1. **MUSS** `handover.md` schreiben (Pointer-Format, max 10 Zeilen)
2. Memory-Commit: `git add && git commit && git push`

---

## 9. Kommunikation

- Status-Updates verständlich, kein Code-Jargon
- Rückfragen nur bei strategischen Entscheidungen
- Opus-Eskalation klar begründen
