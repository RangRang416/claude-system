# Claude Code – Globale Arbeitsregeln

**Gilt für JEDES Projekt und JEDE Session.**
**Details bei Bedarf:** Die `@`-Referenzen werden nur geladen, wenn der Kontext sie erfordert.

---

## 0. Session-Start (PFLICHT)

Sonnet ist der **Orchestrator**. Beim Start:

1. **Orchestrator prüft GitHub:** `gh issue list --state open --json number,title` (selbst, 1 Befehl)

2. **Orchestrator liest Status direkt** (kein Subagent):
   - `handover.md` lesen (Pointer-Index, ~10 Zeilen)
   - Falls kein handover.md: letzte 50 Zeilen von `projekt.md` (Sektion "Current")
   - Kosten: ~500 Token statt ~20.000 bei Subagent-Spawn

3. **Neue Issues → IMMER Planner (Opus):**
   Neue GitHub Issues, die nicht in projekt.md stehen = potenzielle Phase-III-Entdeckungen von Ruben.
   - Keine neuen Issues → weiter mit aktuellem Plan aus projekt.md
   - Neue Issues vorhanden → Orchestrator spricht **Empfehlung** aus (Kernfunktion / Nice-to-have)
   - **Ruben entscheidet** (Orchestrator fragt, wartet auf Antwort)
   - Bei Kernfunktion → Planner (Opus) spawnen, bewertet Einordnung in aktuelle Phase II
   - Bei Nice-to-have → Issue bleibt offen für nächste Version, keine Plan-Änderung
   - Der Orchestrator ordnet KEINE neuen Issues selbst ein — das ist Planner-Aufgabe
   - Bereits geplante Issues (in projekt.md mit Akzeptanzkriterien) → Orchestrator arbeitet direkt ab

4. **Ruben informieren:** "Letzter Stand: [X]. Nächstes: #Y. [Neue Issues: #A, #B — Empfehlung: ...]"

5. Loslegen

**Kein handover.md UND kein projekt.md?** → "Neues Projekt? → Planner (Opus) spawnen."

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

**Definition of Done (nach Klasse):**
- **A:** ✅ Orchestrator-Selbsttest ✅ Commit ✅ CHANGELOG direkt ✅ Ruben informiert
- **B:** ✅ Tester (Sonnet) bestanden ✅ Commit ✅ CHANGELOG direkt ✅ Ruben informiert
- **C:** ✅ Tester bestanden ✅ Reviewer (wenn Security/DB/KI) ✅ Commit ✅ CHANGELOG direkt ✅ Ruben informiert

**Test-vor-Commit-Regel (PFLICHT):**
- Klasse A: Orchestrator testet selbst — kein Tester-Subagent
- Klasse B/C: Tester-Subagent (automatisch) — KEIN Ruben-Browsertest in Phase II
- Ruben-Browsertest gehört in Phase III (nach Deployment, fachliche Prüfung)
- Push zu Remote ERST nach bestandenem Test + Ruben-Freigabe

---

### 2.1 Issue-Klassifizierung (Orchestrator entscheidet VOR Bearbeitung)

| Klasse | Kriterien | Pipeline |
|--------|-----------|----------|
| **A — Trivial** | 1 Datei, kein neues Verhalten, CSS/Config/Doku/Typo/1-Zeiler | Orchestrator direkt (0 Subagenten) |
| **B — Standard** | 2–4 Dateien, neue Logik, kein Security/KI/Schema-Change | Implementer → Tester (Sonnet) |
| **C — Komplex** | 5+ Dateien ODER Security ODER KI ODER DB-Migration ODER nicht reproduzierbar | Planner → Implementer → Tester → Reviewer (nur bei Security/DB/KI) |

**Entscheidungsbaum (2–3 Sekunden):**
1. Nur 1 Datei UND kein neues Verhalten? → **A**
2. Security/KI/DB-Schema/5+ Dateien/nicht reproduzierbar? → **C**
3. Alles andere → **B**

**CHANGELOG:** Orchestrator schreibt immer direkt — kein Subagent-Spawn (Overhead übersteigt Nutzen).

---

## 3. Subagenten-Workflow

Sonnet (Orchestrator) spawnt spezialisierte Agenten aus `.claude/agents/`.
Kein manueller Modellwechsel. Keine handover.md innerhalb einer Session.

### Rollen & Rechte-Matrix

| Rolle | Modell | Code | Doku | Git | Tests | Deploy | Architektur | Lesen/Suchen |
|-------|--------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Orchestrator** | Sonnet | - | - | **commit/push**¹ | - | - | - | ja |
| Planner | Opus | - | - | - | - | - | **ja** | ja |
| Implementer | Sonnet* | **ja** | - | - | - | - | - | ja |
| Tester | dynamisch | - | - | - | **ja** | - | - | ja |
| Reviewer | dynamisch | - | - | - | - | - | - | ja |
| Deployer | Sonnet | - | - | - | - | **ja**¹ | - | ja |

¹ = Nur nach Rubens Freigabe · *oder wie vom Planner zugewiesen

**Tool-Restriktionen:**
- **Planner (Opus):** Darf Dateien lesen, aber NUR die im Task-Prompt explizit benannten. Kein exploratives Scanning.

### Interne Kommunikation (JSON-Payloads)

Subagenten (Haiku/Opus) kommunizieren mit dem Orchestrator über strukturiertes JSON.
**Verboten:** Einleitungen ("Hier ist mein Bericht..."), Höflichkeitsfloskeln, Prosa-Zusammenfassungen.

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

### Reviewer (nur Klasse C)

Nur spawnen wenn: Security ODER DB-Migration ODER KI-Prompt ODER Tester meldet Auffälligkeiten.
- Security/DB/KI → Opus · Alles andere → Sonnet
- Klasse A und B: **kein Reviewer**

---

## 4. Dokumentation

- `CHANGELOG.md` → nach jedem Commit (Orchestrator direkt)
- `backlog.md` → nach jeder Phase
- `projekt.md` → nach Architekturentscheid (Planner)
- `handover.md` → nur bei Session-Ende über Nacht (Pointer-Format, siehe Section 6)

### Archivierungs-Logik (PFLICHT)

`projekt.md` und `backlog.md` müssen **Lean-Dokumente** bleiben.

**Regel:** Wenn `projekt.md` oder `backlog.md` > 200 Zeilen (~10k Token):
1. Orchestrator verschiebt erledigte Issues/Phasen in `archive_YYYY-MM.md`
2. In der Originaldatei bleibt nur: `→ Archiviert in archive_YYYY-MM.md`
3. Nur aktive Phase + nächste Phase bleiben im Dokument

**Warum:** Jeder Token in projekt.md wird bei jeder Planner-Eskalation mitgelesen. Aufgeblähte Dokumente kosten bei jedem Issue Token.

---

## 5. Rollback

`@docs/rollback.md`

---

## 6. Session-Ende

### handover.md (Pointer-Index — KEINE Prosa)

Die handover.md dient als Pointer-Index für den Orchestrator beim nächsten Session-Start.
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
**Ziel:** ~200 Token. Der Orchestrator liest NUR dieses File beim Start.

### Memory-Commit
```bash
cp /root/.claude/projects/-mnt-c-Users-Ruben/memory/MEMORY.md /root/claude-system/projects/-mnt-c-Users-Ruben/memory/MEMORY.md
cd /root/claude-system && git add projects/-mnt-c-Users-Ruben/memory/MEMORY.md && git commit -m "memory: Session-Stand $(date +%Y-%m-%d)" && git push origin main
```

---

## 7. Projektabschluss

`@docs/projektabschluss.md`

---

## 8. Kommunikation

- Status-Updates in verständlicher Sprache, kein Code-Jargon
- Rückfragen NUR bei strategischen Entscheidungen
- Opus-Eskalation klar begründen
