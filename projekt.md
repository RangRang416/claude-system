# claude-system — projekt.md

**Projekt:** claude-system
**Repo:** https://github.com/RangRang416/claude-system
**Zweck:** Globale Claude Code Workflow-Konfiguration — CLAUDE.md, Agent-Templates, Docs, Skills, Mindmaps. Steuert das Verhalten aller Claude Code Sessions projektübergreifend.
**Scope:** Keine Anwendungslogik, kein Server, keine DB. Reine Konfigurations- und Regelwerk-Pflege.
**Version:** v1.0 (Erstplanung 2026-04-02, Planner/Opus)

---

## Architektur

### Dateistruktur (autoritativ)
- `/root/.claude/CLAUDE.md` — Vollversion der Arbeitsregeln (~370 Zeilen)
- `/mnt/c/Users/Ruben/.claude/CLAUDE.md` — Kompaktversion (~107 Zeilen, Projekt-Ebene)
- `/root/.claude/docs/` — Detail-Dokumente (eskalation, rollback, projekt-start, projektabschluss)
- `/root/.claude/agents/` — Agent-Templates (planner, implementer, tester, reviewer, deployer, scout)
- `/root/.claude/docs/templates/` — 8 Templates
- `/root/.claude/skills/` — Wiederverwendbare Skill-Definitionen
- `/root/.claude/mindmaps/` — Projekt-Mindmaps

### Zwei-Datei-Architektur (CLAUDE.md)
Die Vollversion (`/root/.claude/CLAUDE.md`) ist die Single Source of Truth.
Die Kompaktversion (`/mnt/c/Users/Ruben/.claude/CLAUDE.md`) ist ein manuell gepflegter Auszug.
Änderungen IMMER zuerst in der Vollversion. Kompaktversion danach synchronisieren.
Kompaktversion zeigt nur MUSS/MUSS NICHT — bleibt unter 120 Zeilen.

---

## Regelschema (Architektur-Entscheidung aus #22)

### Vier Kategorien (RFC-2119-Anlehnung, Deutsch)

| Marker | Bedeutung | Kriterium |
|--------|-----------|-----------|
| **MUSS** | Harte Pflicht, keine Ausnahme | Verstoss = irreversibel ODER beobachteter Wiederholungsfehler ODER Security/Datenverlust |
| **MUSS NICHT** | Hartes Verbot | Gleiche Kriterien wie MUSS |
| **SOLL** | Starke Empfehlung, Abweichung nur mit dokumentierter Begründung | Normalfall klar, Kontext kann Ausnahme rechtfertigen |
| **KANN** | Option, Ermessen des ausführenden Modells | Mehrere gleichwertige Wege |

### Anti-Inflation: Max. 15 MUSS-Regeln
Jede neue MUSS-Regel braucht `why_must:` mit konkretem Vorfall oder Konsequenz.
Jährliche Review: Planner prüft ob MUSS-Regeln noch begründet sind (Trigger: Versionswechsel).

### Syntaktische Markierung
Marker als **FETTSCHRIFT** im Fliesstext, immer am Anfang der Verhaltensanweisung.

---

## Smoke-Test

**Nicht anwendbar.** claude-system enthält keinen deployten Service. Änderungen wirken erst in der nächsten Claude Code Session. Validation durch Regelanwendung in Folge-Sessions (Phase III).

---

## Aktuelle Phase: Phase II — Regelwerk-Konsolidierung

### Abgeschlossene Issues (archiviert)
- #7–#11: Grundlegende Workflow-Regeln
- #16, #17, #18, #36: Planner-Workflow-Lücken geschlossen (2026-03-25)

### Aktive Issues (Batch "Regelqualität")

**Reihenfolge:** #22 → #20 → #23 → #19 → #24 → #21

| Issue | Titel | Klasse | Blockiert durch |
|-------|-------|--------|-----------------|
| #22 | Regelformulierung: Imperative vs. Ermessen trennen | C | — |
| #20 | Session-Start: Orchestrator liest handover.md selbst | B | #22 |
| #23 | Vor Planner-Spawn: Issue-Kommentare vollständig lesen | A+ | #22 |
| #19 | Planner-Output nicht gegen Issue-Methodik geprüft | B | #22 |
| #24 | Planner Effort-Level bei Architektur-Entscheidungen | A | #22 |
| #21 | Critic-Agent: Planner-Output unabhängig prüfen | C | #19 |

---

## Akzeptanzkriterien

### #22 — Regelformulierung
1. **Was:** Jede Verhaltensregel in CLAUDE.md Vollversion trägt einen der vier Marker. Max. 15 MUSS-Regeln. Kompaktversion konsistent.
2. **Wie:** `grep -cE '(MUSS |MUSS NICHT|SOLL |KANN )' /root/.claude/CLAUDE.md` → >= 20. `grep -c 'MUSS ' /root/.claude/CLAUDE.md` → <= 15. Stichprobe 5 Regeln manuell.
3. **Ergebnis:** >= 20 markierte Regeln, <= 15 MUSS, 0 verwaiste (PFLICHT)-Marker, Kompaktversion spiegelt MUSS/MUSS NICHT.
4. **Modell:** Implementer Sonnet, Tester Haiku, Reviewer Haiku

### #20 — Session-Start
1. **Was:** Schritt 2 beschreibt dass Orchestrator handover.md SELBST liest. Scout-Spawn als SOLL mit Bedingung.
2. **Wie:** `grep -A5 'Session-Start' /root/.claude/CLAUDE.md` — Schritt 2 enthält "Orchestrator liest" statt "Scout spawnen".
3. **Ergebnis:** Kein unbedingter Scout-Spawn in Schritt 2. Scout bleibt SOLL mit Bedingung.
4. **Modell:** Implementer Sonnet, Tester Haiku

### #23 — Issue-Kommentare
1. **Was:** Planner-Spawn-Pflichtschritte erwähnen explizit Kommentare. Befehl: `gh issue view <NR> --comments`.
2. **Wie:** `grep -c 'comments' /root/.claude/CLAUDE.md` → >= 1.
3. **Ergebnis:** MUSS-Marker, Befehl explizit mit `--comments`.
4. **Modell:** Implementer Haiku, Tester Haiku

### #19 — Planner-Output Methodik-Abgleich
1. **Was:** Nach Review-Loop (#18) existiert Checkliste mit 4 Prüfpunkten: (a) 4 Pflichtbestandteile, (b) why:-Feld, (c) Modellzuordnung, (d) Abhängigkeiten.
2. **Wie:** `grep -A10 'Review-Loop nach Planner' /root/.claude/CLAUDE.md` — Checkliste sichtbar.
3. **Ergebnis:** Checkliste als MUSS markiert, >= 4 Prüfpunkte.
4. **Modell:** Implementer Sonnet, Tester Haiku

### #24 — Planner Effort-Level
1. **Was:** Im Planner-Abschnitt steht Anweisung für max effort bei Architektur-Issues.
2. **Wie:** `grep -i 'effort' /root/.claude/CLAUDE.md` → Treffer im Planner-Kontext.
3. **Ergebnis:** Formulierung als SOLL. Abweichung nur bei trivialen Entscheidungen.
4. **Modell:** Orchestrator direkt (Klasse A)

### #21 — Critic-Agent
1. **Was:** (a) `critic.md` in agents/. (b) Rechte-Matrix enthält Critic. (c) Trigger definiert (Klasse C, nach Planner-Output). (d) Critic prüft gegen Checkliste aus #19.
2. **Wie:** `ls /root/.claude/agents/critic.md` + `grep 'Critic' /root/.claude/CLAUDE.md`.
3. **Ergebnis:** critic.md existiert, Rolle in Matrix, Trigger als SOLL bei Klasse C.
4. **Modell:** Implementer Sonnet, Tester Sonnet, Reviewer Haiku
