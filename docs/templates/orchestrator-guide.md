# Orchestrator-Guide — CLAUDE.md als Subagenten-Logik

**Orchestrator-Modell:** Sonnet (günstig, läuft dauerhaft)
**Basis:** Globale CLAUDE.md — dieser Guide übersetzt die dortigen Regeln in automatische Subagenten-Aufrufe.

---

## Grundprinzip

Der Orchestrator (Sonnet) = **"Gesamtaufsicht Phase II"** aus der CLAUDE.md.
Er liest den Opus-Plan (projekt.md), delegiert an das jeweils richtige Modell,
überwacht Fortschritt, führt Tests durch (wo zugewiesen).

**Kernregel:** Jeder Subagent bekommt NUR den Kontext, den er braucht.
Kein CLAUDE.md, kein memory.md, keine handover.md — nur sein Auftrag.

**Token-Effizienz-Regeln:**
- Scout bekommt nur Datei-Pointer, keine Beschreibungen
- Planner bekommt nur die relevanten Dateipfade, liest selbst gezielt
- Alle Subagenten antworten in JSON, keine Prosa
- handover.md = Pointer-Index (~200 Token), keine Zusammenfassung

**Was der Orchestrator NICHT tut:**
- Architekturentscheidungen treffen (→ PLANNER/Opus)
- KI-Prompts schreiben (→ PLANNER/Opus)
- Opus-Aufgaben selbst versuchen (→ PLANNER spawnen)

---

## Rollenverteilung (aus CLAUDE.md Section 3)

| CLAUDE.md-Rolle | Subagent | Modell | Token-Budget | Wann |
|-----------------|----------|--------|:---:|------|
| **Status-Retrieval** | SCOUT | **Haiku** | < 2k / < 8k | Session-Start (Status-Check) / Vor Impl. (Datei-Erkundung) |
| **Projekt-Kopf** | PLANNER | **Opus (immer)** | ~3k | Phase I, Architektur, Eskalation, Sub-Issues |
| **Gesamtaufsicht** | ORCHESTRATOR | **Sonnet** | — | Läuft dauerhaft, delegiert, überwacht |
| **Umsetzung** | IMPLEMENTER | **Sonnet*** | ~2k | Code schreiben, ein Issue pro Aufruf |
| **Test** | TESTER | **dynamisch** | ~300-1k | Nach jeder Implementierung |
| **Review** | REVIEWER | **dynamisch** | ~300-1.5k | Nach bestandenem Test |
| **Dokumentation** | DOCUMENTER | **Haiku** | < 1.5k | CHANGELOG, backlog — nach Test |
| **Deployment** | DEPLOYER | **Sonnet** | ~500 | Nur nach Rubens Freigabe |

---

## Subagent-Aufruf-Referenz

### SCOUT (Haiku — Zwei Modi)

**Modus A: Status-Check (Session-Start)**
```
Task(
  description: "Status-Check [Projekt]",
  subagent_type: "scout",
  model: "haiku",
  prompt: "Modus: STATUS-CHECK. Lies NUR {{REPO_PATH}}/handover.md.
           Falls nicht vorhanden: letzte 50 Zeilen von {{REPO_PATH}}/projekt.md.
           Antworte NUR mit JSON: {issue_current, issue_next, new_issues, blockers, files_last, hint}"
)
```
**Token-Budget:** < 2.000. **Max Tool-Aufrufe:** 2.

**Modus B: Datei-Erkundung (vor Implementierung)**
```
Task(
  description: "Scout Dateien für [Issue]",
  subagent_type: "scout",
  model: "haiku",
  prompt: "Modus: DATEI-ERKUNDUNG. Lies NUR diese Dateien: {{FILE_LIST}}.
           Kontext: Issue {{ISSUE_REF}}.
           Antworte NUR mit JSON: {files: [{path, summary, dependencies}], patterns, blockers}"
)
```
**Token-Budget:** < 8.000. **Nur benannte Dateien.**

### PLANNER (Opus — IMMER)
```
Task(
  description: "Plan [Thema]",
  subagent_type: "planner",
  model: "opus",
  prompt: [Template aus planner.md + explizite Dateipfade]
)
```
**Wann:**
- Neues Projekt / neue Phase (Phase I komplett)
- Architekturentscheidung nötig
- Eskalation (Test 2x fehlgeschlagen, Ursache unklar, 2+ Systemebenen)
- Sub-Issues erstellen (= Mini Phase I durch Opus)
- KI-Prompt-Engineering, Regex für Texterkennung
- DB-Schema-Änderungen mit Migration
- Security-relevante Logik (Auth, CSRF)
- Performance-Diagnose
- Nicht reproduzierbare Fehler

**Was Opus liefert (4 Pflichtbestandteile pro Issue):**
1. Was genau wird geprüft? (konkrete Funktion oder Verhalten)
2. Wie wird getestet? (exakter Befehl, Eingabe oder Aktion)
3. Was ist das erwartete Ergebnis? (konkret und messbar)
4. Welches Modell setzt um? (pro Teilaufgabe)

**Ohne Testmethode UND Modellzuordnung darf kein Issue existieren.**

### IMPLEMENTER (Sonnet — oder wie vom Planner zugewiesen)
```
Task(
  description: "Implement [Issue]",
  subagent_type: "general-purpose",
  model: "sonnet",  // oder was Planner festgelegt hat
  prompt: [Template aus implementer.md]
)
```
**Optional:** `isolation: "worktree"` bei riskanten Änderungen

### TESTER (dynamisches Modell — Orchestrator wählt VOR dem Spawnen)
```
Task(
  description: "Test [Issue]",
  subagent_type: "tester",
  model: [siehe Entscheidungslogik unten],
  prompt: [Template aus tester.md]
)
```
**Modellwahl:**
- Nur CSS/Config/Doku oder 1 triviale Datei → `"haiku"`
- Security/KI-Prompt/nicht reproduzierbar → `"opus"`
- Alles andere → `"sonnet"` (Standardfall)

**WICHTIG:** Der Tester-Subagent führt NUR technische Tests aus (Befehle, curl, DB-Queries).
Browsertests durch Ruben gehören in Phase III — NIEMALS in Phase II verlangen.

### REVIEWER (dynamisches Modell)
```
Task(
  description: "Review [Issue]",
  subagent_type: "general-purpose",
  model: [siehe Entscheidungslogik],
  prompt: [Template aus reviewer.md]
)
```
**Modellwahl (abhängig von Test-Ergebnis):**
- **Haiku** → CSS, Config, Tippfehler, Doku (immer)
- **Haiku** → Standard-Code, wenn Tester BESTANDEN (Sanity-Check reicht)
- **Sonnet** → Standard-Code, wenn Tester NICHT BESTANDEN oder Ergebnis unklar
- **Opus** → Security, DB-Schema, Architektur, KI-Prompts (immer, unabhängig vom Test)

### DOCUMENTER (Haiku)
```
Task(
  description: "Document [Issue]",
  subagent_type: "general-purpose",
  model: "haiku",
  prompt: [Template aus documenter.md]
)
```

### DEPLOYER (Sonnet)
```
Task(
  description: "Deploy [Issue]",
  subagent_type: "Bash",
  model: "sonnet",
  prompt: [Template aus deployer.md]
)
```
**NUR nach Rubens expliziter Freigabe.**

---

## Orchestrierungs-Ablauf pro Issue (CLAUDE.md Section 2)

```
1. ISSUE LESEN
   → Orchestrator liest Issue-Details aus projekt.md / GitHub
   → Prüft: Welche Dateien? Welches Modell hat Planner zugewiesen?

2. IMPLEMENTIEREN
   → Spawnt IMPLEMENTER mit dem vom Planner zugewiesenen Modell
   → Wartet auf Ergebnis
   → STATUS == FERTIG? → weiter zu 3
   → STATUS == BLOCKIERT? → siehe Eskalation

3. TESTEN (Pflicht — keine Ausnahme, auch bei kleinen Änderungen)
   → Spawnt TESTER mit Akzeptanzkriterien aus dem Opus-Plan
   → Wartet auf Ergebnis
   → BESTANDEN? → weiter zu 4
   → NICHT BESTANDEN? → siehe Eskalation

   Bei reinen Doku-Commits (kein Code):
   → Kein funktionaler Test möglich → EXPLIZIT benennen vor Commit

4. REVIEW
   → Orchestrator wählt Review-Modell (Haiku/Sonnet/Opus)
   → Spawnt REVIEWER
   → APPROVED? → weiter zu 5
   → CHANGES_REQUESTED? → IMPLEMENTER erneut mit Befunden

5. COMMIT
   → Orchestrator macht selbst: git add + git commit
   → Commit-Message mit Issue-Referenz (Fixes #X)

6. DOKUMENTIEREN
   → Spawnt DOCUMENTER (Haiku): CHANGELOG + backlog

7. ABGLEICH MIT PROJEKT.MD (CLAUDE.md Pflicht nach jedem Issue)
   → Orchestrator prüft: Stimmt Umsetzung noch mit Opus-Plan überein?
   → Falls Abweichung → PLANNER spawnen für Korrektur der projekt.md
   → Falls plangemäß → nächstes Issue

8. RUBEN INFORMIEREN (Definition of Done)
   → "Issue #X abgeschlossen."
   → "Test: [was getestet]. Ergebnis: [was beobachtet]."
   → "Nächstes: #Y."

9. DEPLOY / PUSH (nur auf Anfrage)
   → Ruben sagt "deploy" oder "push"
   → Spawnt DEPLOYER / führt git push aus
```

---

## Eskalationslogik (CLAUDE.md Section 3 — 1:1 übernommen)

```
Test schlägt fehl
  │
  → Orchestrator analysiert TESTER-Ergebnis
    │
    ├─ EINFACH (1 Ursache, 1 Systemebene)
    │   → IMPLEMENTER erneut spawnen mit Fehler-Details
    │   → TESTER erneut spawnen
    │   → Wenn 2. Versuch AUCH fehlschlägt:
    │     → PLANNER (Opus) spawnen = PFLICHT
    │     → Kein 3. Versuch durch Sonnet
    │
    ├─ KOMPLEX (2+ unabhängige Ursachen ODER 2+ Systemebenen)
    │   → PLANNER (Opus) spawnen = PFLICHT
    │   → Opus erstellt Sub-Issues (= Mini Phase I):
    │     - Akzeptanzkriterien pro Sub-Issue
    │     - Modellzuordnung pro Sub-Issue
    │     - Testverfahren pro Sub-Issue
    │   → Orchestrator arbeitet Sub-Issues nacheinander ab
    │     (gleicher Ablauf: IMPLEMENTER → TESTER → REVIEWER → COMMIT)
    │
    └─ URSACHE UNKLAR
        → PLANNER (Opus) spawnen = PFLICHT
        → Kein weiteres Probieren durch Orchestrator/Sonnet
        → Opus analysiert und liefert entweder Fix-Plan oder Sub-Issues

Max 2 Testversuche durch IMPLEMENTER+TESTER. Danach Opus, egal was.
```

### Opus-Pflicht-Trigger (direkt, kein Eskalations-Schwellenwert)

Bei diesen Aufgaben IMMER sofort PLANNER (Opus) spawnen:

| Trigger | Warum Opus |
|---------|-----------|
| KI-Prompt-Engineering | Prompt-Qualität entscheidet über Systemverhalten |
| Regex für Texterkennung | Komplexe Pattern brauchen präzises Denken |
| Nicht reproduzierbare Fehler | Systematische Analyse nötig |
| Security-relevante Logik (Auth, CSRF) | Kein Raum für Fehler |
| DB-Schema-Änderungen mit Migration | Irreversibel, Datenverlust-Risiko |
| Performance-Diagnose | Ursachenanalyse braucht Tiefe |
| Refactoring 3+ Dateien gleichzeitig | Sonnet verliert Import-Bezüge bei dateiübergreifenden Änderungen |

---

## Sub-Issue-Flow (CLAUDE.md: "Sub-Issues = neue Issues mit vollem Phase-I-Zyklus")

```
Orchestrator erkennt: Issue zu komplex / Test 2x fehlgeschlagen
  │
  ├─ 1. Spawnt PLANNER (Opus) mit Problembeschreibung
  │     Opus liefert: Sub-Issues mit Akzeptanzkriterien + Modellzuordnung
  │
  ├─ 2. Orchestrator erstellt Sub-Issues (GitHub / intern)
  │
  ├─ 3. Orchestrator arbeitet Sub-Issues NACHEINANDER ab:
  │     Sub-Issue A: IMPLEMENTER → TESTER → REVIEWER → COMMIT
  │     Sub-Issue B: IMPLEMENTER → TESTER → REVIEWER → COMMIT
  │     ...
  │
  ├─ 4. Nach allen Sub-Issues: TESTER für Original-Issue spawnen
  │     (Gesamttest gegen Original-Akzeptanzkriterien)
  │
  └─ 5. Wenn Gesamttest bestanden → Original-Issue abschließen
        Wenn nicht → Ruben informieren, nicht weiter eskalieren
```

---

## Parallelisierungs-Regeln

**Parallel starten (spart Zeit):**
- DOCUMENTER + Vorbereitung nächstes Issue
- Mehrere unabhängige Reads/Greps
- TESTER + REVIEWER (wenn Review-Scope nur Syntax/Haiku)

**NIEMALS parallel:**
- IMPLEMENTER → TESTER (Test braucht fertigen Code)
- TESTER → REVIEWER (Review braucht Testergebnis bei Standard/Opus-Review)
- IMPLEMENTER → COMMIT (Commit braucht fertigen Code)
- Sub-Issue A → Sub-Issue B (sequenziell, es sei denn explizit unabhängig)

---

## Definition of Done (CLAUDE.md Section 2 — gilt für JEDES Issue)

Ein Issue gilt erst als abgeschlossen wenn:
- [ ] Test gemäß Akzeptanzkriterien durchgeführt (Test-Nachweis dokumentiert)
- [ ] Abgleich mit Akzeptanzkriterien aus Opus-Plan erfolgt
- [ ] Commit mit Issue-Referenz gemacht
- [ ] CHANGELOG.md aktualisiert
- [ ] Ruben informiert: "Issue #X abgeschlossen, Test: [was], Ergebnis: [was]"

**Test-Nachweis (Pflicht bei jedem Test):**
```
TEST-NACHWEIS Issue #X:
- Was getestet: [konkrete Funktion/Verhalten]
- Wie getestet: [exakter Befehl, Eingabe oder Aktion]
- Ergebnis: [was beobachtet wurde]
- Status: BESTANDEN / NICHT BESTANDEN
```

---

## Token-Tracking

Nach jedem Issue dokumentiert der Orchestrator (intern):
- Wie viele Subagenten gespawnt (Typ + Modell)
- Geschätzter Token-Verbrauch pro Subagent
- Gesamtverbrauch fürs Issue
- Vergleich mit geschätztem manuellem Verbrauch (~40.000-60.000)

---

## Archivierungs-Logik

`projekt.md` und `backlog.md` müssen Lean-Dokumente bleiben.

**Regel:** Wenn > 200 Zeilen (~10k Token):
1. Orchestrator verschiebt erledigte Issues/Phasen in `archive_YYYY-MM.md`
2. In der Originaldatei bleibt nur: `→ Archiviert in archive_YYYY-MM.md`
3. Nur aktive Phase + nächste Phase bleiben im Dokument

**Warum:** Jeder Token in projekt.md wird bei Scout- und Planner-Aufrufen mitgelesen.

---

## handover.md Format (Pointer-Index)

Die handover.md wird beim Session-Ende geschrieben und beim nächsten Start vom Scout gelesen.
**Keine Prosa, keine Zusammenfassungen. Nur Pointer.**

```
issue_current: #17
issue_next: #18
status: impl_done, test_pending
files_changed:
  - app/import.php
  - app/db.php
projekt_md_section: "Phase II, Issue #17"
blockers: none
note: "DB-Migration noch nicht deployed"
```

**Ziel:** ~200 Token. Der Scout braucht nur 1 Read-Aufruf.
