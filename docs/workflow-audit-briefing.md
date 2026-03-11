# Briefing: Workflow-Audit für Planner (Opus)

**Erstellt:** 2026-03-11
**Auftraggeber:** Ruben (Orchestrator-Session Vorgangs-Manager v1.7)
**Ziel:** Opus soll den globalen Workflow (CLAUDE.md + Agent-Configs) auditieren und optimieren.

---

## Kontext: Warum dieser Audit?

Ruben hat den globalen Workflow über mehrere Monate schrittweise entwickelt.
Das Grundprinzip — **"so dezidiert wie notwendig, so einfach/effizient/token-sparsam wie möglich"** — wird noch nicht konsequent umgesetzt.

**Konkretes Auslöser-Beispiel aus dieser Session:**

Issue #49 (Vorgangs-Manager): Additive Änderung — SQL-Subquery + HTML-Spalte + 1 CSS-Zeile.
Tester wurde mit Sonnet gespawnt (weil Regel: "2+ Dateien → Sonnet").
Tatsächliche Tests: 4× grep, 1× php -l, 1× simpler DB-Query.
**Ergebnis: ~33k Token für Haiku-Arbeit.**

CLAUDE.md Regel war zu grob: "2 Dateien = Sonnet" — unabhängig davon ob die Tests trivial sind.

---

## Bekannte Schwachstellen (gesammelt aus Sessions)

### 1. Tester-Modellwahl zu grob
**Ist:** `CSS/Config/1 Datei → Haiku | 2+ Dateien/DB → Sonnet | Security/KI → Opus`
**Problem:** "2+ Dateien" triggert Sonnet auch wenn beide Änderungen trivial sind (z.B. 1 CSS-Zeile + 1 SQL-Subquery ohne Logik).
**Lösungsansatz:** Kriterium sollte die TESTMETHODE sein, nicht die Dateianzahl.

### 2. Reviewer-Einsatz unklar
**Frage:** Wann ist ein Reviewer wirklich notwendig vs. der Tester ausreichend?
Aktuell: Reviewer nur bei Klasse C + Security/DB/KI. Aber was genau prüft er zusätzlich zum Tester?
**Vermutung:** Reviewer wird zu selten/falsch eingesetzt, weil die Abgrenzung zum Tester nicht klar ist.

### 3. Klasse-A/B/C-Grenze und Spawn-Entscheidung
Scout wurde bereits abgeschafft (zu teuer, ~18-20k Token Overhead für triviale Reads).
Documenter wurde bereits abgeschafft (CHANGELOG schreibt Orchestrator direkt).
**Frage:** Gibt es weitere Spawns die den Overhead nicht rechtfertigen?

### 4. CLAUDE.md vs. Agent-Configs: Zwei Wahrheitsquellen
Regeln stehen in CLAUDE.md (globale Workflow-Regeln) UND in Agent-Definitionen (/root/.claude/agents/*.md).
Bei Änderungen muss man beide synchron halten — fehleranfällig.
**Frage:** Wo ist die Single Source of Truth? Wie vermeidet man Drift?

### 5. Spawn-Overhead-Realität
Jeder Subagent-Spawn kostet ~18-20k Token System-Overhead (Claude Code Infrastruktur, nicht kontrollierbar).
→ Breakeven: Subagent lohnt erst ab ~15-20k Token eigener Arbeit.
→ Haiku-Spawns für triviale Tasks (< 5k Token Arbeit) sind IMMER ineffizient.
**Frage:** Welche Spawn-Entscheidungen im aktuellen Workflow sind unter diesem Breakeven?

---

## Was Opus tun soll

### Schritt 1: Alle relevanten Dateien lesen

Lies NUR diese Dateien (keine explorative Suche):
- `/root/.claude/CLAUDE.md`
- `/mnt/c/Users/Ruben/.claude/CLAUDE.md`
- `/root/.claude/agents/tester.md`
- `/root/.claude/agents/reviewer.md`
- `/root/.claude/agents/implementer.md`
- `/root/.claude/agents/planner.md`
- `/root/.claude/docs/eskalation.md`
- `/root/.claude/docs/templates/tester.md`
- `/root/.claude/docs/templates/reviewer.md`

### Schritt 2: Auditieren nach diesem Prinzip

**Leitfrage pro Regel:** "Ist diese Regel so einfach/effizient/token-sparsam wie möglich — und trotzdem so präzise wie für korrekte Entscheidungen nötig?"

Prüfe spezifisch:
1. **Tester-Modellwahl:** Neue Regel formulieren die TESTMETHODE (was der Tester tut) als Kriterium nutzt, nicht Dateianzahl
2. **Reviewer-Abgrenzung:** Klare Definition wann Reviewer nötig ist (vs. Tester ausreichend). Wann deckt der Tester bereits ab was der Reviewer prüfen würde?
3. **Spawn-Breakeven:** Welche Spawns sind unter dem ~18-20k Token Breakeven? Empfehlung: abschaffen oder in Orchestrator direkt integrieren
4. **CLAUDE.md vs. Agent-Config Drift:** Wie soll die Synchronität sichergestellt werden? Regel vorschlagen.
5. **Klasse A/B/C-Abgrenzung:** Ist die 3-Klassen-Logik noch optimal oder gibt es Grenzfälle die regelmäßig falsch klassifiziert werden?

### Schritt 3: Korrekturen schreiben

Opus liefert **konkrete Änderungsvorschläge** (kein Prosa-Report):
- Für CLAUDE.md: exakte neue Regel-Texte (nicht Beschreibungen davon)
- Für Agent-Configs: exakte neue Abschnitte
- Mit Begründung (1 Satz pro Änderung)
- Priorisiert: Was bringt am meisten Token-Ersparnis / Klarheitsgewinn?

---

## Randbedingungen

- Rubens Stil: Kein Over-Engineering, keine hypothetischen Future-Proofing-Regeln
- Spawn-Overhead ist REAL und NICHT kontrollierbar (~18-20k pro Spawn, Haiku/Sonnet/Opus gleich)
- Alle Agenten spawnen in Claude Code — keine externen API-Calls
- Bestehende Struktur beibehalten wo sie funktioniert (nicht alles umwerfen)
- Änderungen müssen in BEIDE CLAUDE.md-Dateien UND die relevanten Agent-Config-Files

---

## Erwartetes Ergebnis

Ein Dokument `/root/claude-system/docs/workflow-audit-ergebnis.md` mit:
1. Liste der Änderungen (priorisiert)
2. Exakte neue Texte für jede Änderung (copy-paste-ready)
3. Begründung pro Änderung (1-2 Sätze)
4. Schätzung der Token-Einsparung pro Änderung (grob)

Der Orchestrator implementiert die Änderungen dann in einer separaten Session.

---

## Zusatz: Autorisierungs-Anfragen (DRINGLICH)

**Problem:** Claude Code fragt bei fast jedem Tool-Call nach Bestätigung — auch bei harmlosen Bash-Befehlen, Reads, SCPs. Das unterbricht den Flow ständig und kostet Zeit und Nerven.

**Rubens Wunsch (explizit):** Bash-Commands, File-Reads, SCP-Uploads, Deploys laufen OHNE Rückfrage durch. Nur bei Architekturentscheidungen, Blockern, strategischen Weichenstellungen oder Push zu Remote soll gefragt werden.

**Was Opus prüfen soll:**
1. Wo in Claude Code werden Permissions konfiguriert? (`settings.json`, `.claude/settings.json`, `claude_code_config.json`?)
2. Welche Permission-Modes gibt es? (autoApprove, bypassPermissions, allowedTools etc.)
3. Wie kann man für dieses Projekt / global konfigurieren dass bestimmte Tool-Kategorien (Bash, Read, Write, Edit, SCP) ohne Bestätigung laufen?
4. Gibt es eine `CLAUDE.md`-Direktive die das steuert, oder muss es in einer Config-Datei sein?

**Relevante Config-Dateien zum Lesen:**
- `/root/.claude/settings.json`
- `/mnt/c/Users/Ruben/.claude/settings.json` (falls vorhanden)
- `/root/.claude/claude_code_config.json`

**Erwartetes Ergebnis:** Konkrete Konfigurationsänderung die das Problem löst — einmalig setzen, dauerhaft wirkt.
