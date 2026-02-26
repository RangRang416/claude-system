# Claude Code – Globale Arbeitsregeln

**Gilt für JEDES Projekt und JEDE Session.**
**Details bei Bedarf:** Die `@`-Referenzen werden nur geladen, wenn der Kontext sie erfordert.

---

## 0. Session-Start (PFLICHT)

Sonnet ist der **Orchestrator**. Beim Start:

1. **Orchestrator prüft GitHub:** `gh issue list --state open --json number,title` (selbst, 1 Befehl)

2. **Scout (Haiku) spawnen — Modus: STATUS-CHECK**
   - Scout liest NUR: `handover.md` (Pointer-Index, ~10 Zeilen)
   - Falls kein handover.md: letzte 50 Zeilen von `projekt.md` (Sektion "Current")
   - **VERBOTEN:** Repo-Scans, Glob/Grep, Code-Dateien lesen, Bash, `ls -R`
   - **Token-Budget:** < 2.000 gesamt
   - Scout liefert JSON:
     ```json
     {"issue_current": "#17", "issue_next": "#18",
      "blockers": "none", "files_last": ["app/import.php"], "hint": ""}
     ```

3. **Orchestrator kombiniert:** Scout-JSON + GitHub-Issues → erkennt neue Issues

4. **Neue Issues → IMMER Planner (Opus):**
   Neue GitHub Issues, die nicht in projekt.md stehen = potenzielle Phase-III-Entdeckungen von Ruben.
   - Keine neuen Issues → weiter mit aktuellem Plan aus projekt.md
   - Neue Issues vorhanden → Orchestrator spricht **Empfehlung** aus (Kernfunktion / Nice-to-have)
   - **Ruben entscheidet** (Orchestrator fragt, wartet auf Antwort)
   - Bei Kernfunktion → Planner (Opus) spawnen, bewertet Einordnung in aktuelle Phase II
   - Bei Nice-to-have → Issue bleibt offen für nächste Version, keine Plan-Änderung
   - Der Orchestrator ordnet KEINE neuen Issues selbst ein — das ist Planner-Aufgabe
   - Bereits geplante Issues (in projekt.md mit Akzeptanzkriterien) → Orchestrator arbeitet direkt ab

5. **Ruben informieren:** "Letzter Stand: [X]. Nächstes: #Y. [Neue Issues: #A, #B — Empfehlung: ...]"

6. Loslegen

**Kein handover.md UND kein projekt.md?** → "Neues Projekt? → Planner (Opus) spawnen."

### Scout Zwei-Modi-System

| Modus | Zweck | Erlaubte Reads | Token-Budget |
|-------|-------|---------------|-------------|
| **Status-Check** | Session-Start: Wo stehen wir? | NUR handover.md + projekt.md "Current" | **< 2.000** |
| **Datei-Erkundung** | Vor Implementierung: Kontext sammeln | Nur vom Orchestrator benannte Dateien | **< 8.000** |

**Grundregel:** Der Scout macht RETRIEVAL, keine EXPLORATION. Er liest nur, was ihm gesagt wird.

---

## 1. Projekt-Start & Phasen

Bei neuem Projekt: `@docs/projekt-start.md`

---

## 2. Issue-Bearbeitung

**Reihenfolge:** Ein Issue nach dem anderen. Kein paralleles Arbeiten.
**Ablauf & Eskalation:** `@docs/eskalation.md`

**Akzeptanzkriterien (4 Pflichtbestandteile pro Issue):**
1. Was genau wird geprüft?
2. Wie wird getestet? (exakter Befehl/Aktion)
3. Erwartetes Ergebnis? (konkret, messbar)
4. Welches Modell setzt um? (Opus/Sonnet/Haiku)

**Definition of Done:**
- ✅ Test gemäß Akzeptanzkriterien (Methode + Ergebnis dokumentiert)
- ✅ Commit mit Issue-Referenz
- ✅ CHANGELOG.md aktualisiert
- ✅ Ruben informiert: "Issue #X abgeschlossen, Test: [was], Ergebnis: [was]"

**Test-vor-Commit-Regel (PFLICHT):**
- Vor JEDEM Commit testen — bei reinen Doku-Commits EXPLIZIT begründen warum kein Test
- Test = Tester-Subagent (automatisch, Phase II) — KEIN Ruben-Browsertest in Phase II
- Ruben-Browsertest gehört in Phase III (nach Deployment, fachliche Prüfung)
- Push zu Remote ERST nach bestandenem Test + Ruben-Freigabe

---

## 3. Subagenten-Workflow

Sonnet (Orchestrator) spawnt spezialisierte Agenten aus `.claude/agents/`.
Kein manueller Modellwechsel. Keine handover.md innerhalb einer Session.

### Rollen & Rechte-Matrix

| Rolle | Modell | Code | Doku | Git | Tests | Deploy | Architektur | Lesen/Suchen |
|-------|--------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Orchestrator** | Sonnet | - | - | **commit/push**¹ | - | - | - | ja |
| Scout | Haiku | - | - | - | - | - | - | **nur** |
| Planner | Opus | - | - | - | - | - | **ja** | ja |
| Implementer | Sonnet* | **ja** | - | - | - | - | - | ja |
| Tester | dynamisch | - | - | - | **ja** | - | - | ja |
| Reviewer | dynamisch | - | - | - | - | - | - | ja |
| Documenter | Haiku | - | **ja** | - | - | - | - | ja |
| Deployer | Sonnet | - | - | - | - | **ja**¹ | - | ja |

¹ = Nur nach Rubens Freigabe · *oder wie vom Planner zugewiesen

**Tool-Restriktionen:**
- **Scout:** Keine rekursiven Scans (`ls -R`, Glob `**/*`). Nur gezielte Read-Aufrufe auf benannte Dateien.
- **Planner (Opus):** Darf Dateien lesen, aber NUR die im Task-Prompt explizit benannten. Kein exploratives Scanning.
- **Documenter:** Nur CHANGELOG.md und backlog.md editieren. Token-Cap: 1.500.

### Interne Kommunikation (JSON-Payloads)

Subagenten (Haiku/Opus) kommunizieren mit dem Orchestrator über strukturiertes JSON.
**Verboten:** Einleitungen ("Hier ist mein Bericht..."), Höflichkeitsfloskeln, Prosa-Zusammenfassungen.

**Scout → Orchestrator:**
```json
{"issue_current": "#17", "issue_next": "#18", "new_issues": ["#20 Feature"],
 "blockers": "none", "files_last": ["app/import.php"], "hint": ""}
```

**Alle Subagenten → Orchestrator (nach Abschluss):**
```json
{"status": "done|blocked|failed", "files_touched": ["app/db.php"],
 "result": "kurze Beschreibung", "blockers": "none"}
```

### Opus-Pflicht-Trigger (sofort spawnen)

- KI-Prompt-Engineering
- Regex für Texterkennung
- Nicht reproduzierbare Fehler
- Security (Auth, CSRF)
- DB-Schema mit Migration
- Performance-Diagnose
- Refactoring 3+ Dateien gleichzeitig

### Tester-Modellwahl

| Art der Änderung | Testmethode | Modell |
|-----------------|-------------|--------|
| CSS, Config, Doku, 1 Datei trivial | Syntax/Datei-Check | Haiku |
| Standard-Code, DB, API, 2+ Dateien | Befehle + Logik-Prüfung | Sonnet |
| Security, KI-Prompt, schwer reproduzierbar | Gezielte Angriffsvektoren | Opus |

**Entscheidungslogik (Orchestrator wählt VOR dem Spawnen):**
- Nur Nicht-Code (CSS/Config/Doku) oder 1 triviale Datei → Haiku
- Security/KI-Prompt/nicht reproduzierbar → Opus
- Alles andere → Sonnet (Standardfall)

### Reviewer-Modellwahl

| Änderung | Test bestanden? | Modell |
|----------|:-:|--------|
| CSS, Config, Doku | egal | Haiku |
| Standard-Code | ja | Haiku (Sanity-Check) |
| Standard-Code | nein/unklar | Sonnet |
| Security, DB, Architektur, KI | egal | Opus |

---

## 4. Dokumentation

- `CHANGELOG.md` → nach jedem Commit (Documenter)
- `backlog.md` → nach jeder Phase
- `projekt.md` → nach Architekturentscheid (Planner)
- `handover.md` → nur bei Session-Ende über Nacht (Pointer-Format, siehe Section 6)

### Archivierungs-Logik (PFLICHT)

`projekt.md` und `backlog.md` müssen **Lean-Dokumente** bleiben.

**Regel:** Wenn `projekt.md` oder `backlog.md` > 200 Zeilen (~10k Token):
1. Orchestrator verschiebt erledigte Issues/Phasen in `archive_YYYY-MM.md`
2. In der Originaldatei bleibt nur: `→ Archiviert in archive_YYYY-MM.md`
3. Nur aktive Phase + nächste Phase bleiben im Dokument

**Warum:** Jeder Token in projekt.md wird bei jedem Scout-Aufruf und jeder Planner-Eskalation mitgelesen. Aufgeblähte Dokumente kosten bei jedem Issue Token.

---

## 5. Rollback

`@docs/rollback.md`

---

## 6. Session-Ende

### handover.md (Pointer-Index — KEINE Prosa)

Die handover.md dient als Pointer-Index für den Scout beim nächsten Session-Start.
**Keine Zusammenfassungen, keine Erklärungen, keine Prosa.**

**Format (exakt so, max 10 Zeilen):**
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

**Wann schreiben:**
- **Nach jedem abgeschlossenen Issue** (Absturz-Sicherheit — Pflicht)
- **Am Session-Ende** (finaler Stand)

Bei Absturz ist so mindestens der letzte Issue-Stand gesichert.
**Ziel:** ~200 Token. Der Scout liest NUR dieses File beim Start.

### Memory-Commit
```bash
cd /mnt/c/Users/Ruben/.claude
git add -A && git commit -m "memory: Session-Stand $(date +%Y-%m-%d)" && git push origin main
```

---

## 7. Projektabschluss

`@docs/projektabschluss.md`

---

## 8. Kommunikation

- Status-Updates in verständlicher Sprache, kein Code-Jargon
- Rückfragen NUR bei strategischen Entscheidungen
- Opus-Eskalation klar begründen
