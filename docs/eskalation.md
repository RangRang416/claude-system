# Eskalationslogik & Issue-Ablauf (Detail)

## Testen: Phase II vs. Phase III

Der Tester-Subagent führt **technische Tests** aus (Befehle, curl, DB-Queries, Syntax-Checks).
Browsertests durch Ruben sind **kein Teil des Phase-II-Ablaufs**.

- **Phase II** = Tester-Subagent prüft automatisch: "Läuft der Code technisch?"
- **Phase III** = Ruben testet im Browser: "Reicht der Funktionsumfang in der Praxis?"

Ruben muss in Phase II NIE den Browser öffnen. Erst nach Deployment (Phase III).

## Phase-III-Rückfluss (Rubens Entdeckungen → zurück in Phase II)

Ruben entdeckt beim Praxistest (Phase III) fehlende Funktionen oder Probleme.
Er hält diese als **GitHub Issue** fest — jederzeit, auch außerhalb von Sessions.

**Ablauf beim nächsten Session-Start:**
```
Scout meldet: "Neue Issues: #23, #24"
  │
  → Orchestrator spricht EMPFEHLUNG pro Issue aus:
    │
    ├─ Kernfunktion (ohne sie ist das Feature unbrauchbar)
    │   → Empfehlung: "In aktuelle Version einarbeiten"
    │   → Ruben entscheidet: Ja → Planner bewertet Einordnung in Phase II
    │
    ├─ Bug (etwas funktioniert falsch)
    │   → Empfehlung: "In aktuelle Version fixen"
    │   → Ruben entscheidet: Ja → Direkt in Phase II
    │
    └─ Nice-to-have (Feature funktioniert, könnte aber besser sein)
        → Empfehlung: "Für nächste Version vormerken"
        → Ruben entscheidet: Ja → Issue bleibt offen, keine Plan-Änderung

Ruben hat immer das letzte Wort. Orchestrator fragt, wartet, handelt.
```

**Bei Kernfunktion → Planner (Opus) wird gespawnt:**
- Bewertet: Passt es in ein bestehendes Issue? Neues Sub-Issue? Neues Issue?
- Aktualisiert projekt.md mit neuen Akzeptanzkriterien
- Ordnet in die Phase-II-Reihenfolge ein

## Issue-Abschluss-Flow (Subagenten-Workflow)

Typischer Ablauf eines Issues in Phase II:

```
1. ISSUE LESEN        → Orchestrator (selbst)
2. IMPLEMENTIEREN     → spawnt Implementer (Sonnet)
3. TESTEN             → spawnt Tester (Sonnet) — Pflicht, keine Ausnahme
4. REVIEW             → spawnt Reviewer (Haiku/Sonnet/Opus je nach Komplexität)
5. COMMIT             → Orchestrator (selbst, mit Fixes #X)
6. DOKUMENTIEREN      → spawnt Documenter (Haiku)
7. PLAN-ABGLEICH      → Stimmt Umsetzung mit projekt.md überein?
8. HANDOVER UPDATE    → handover.md aktualisieren (Absturz-Sicherheit)
9. RUBEN INFORMIEREN  → "Issue #X fertig. Test: [was]. Ergebnis: [was]."
10. DEPLOY/PUSH       → nur auf Rubens Anfrage
```

- **Kein Handover nötig** — Orchestrator behält den Kontext
- **Wenn Test NICHT bestanden** → Implementer erneut spawnen (max 2x, dann Planner/Opus)
- **Wenn Review CHANGES_REQUESTED** → Implementer erneut mit Befunden

## Eskalationslogik

```
Test fehlgeschlagen
  → Orchestrator analysiert Tester-Ergebnis
    │
    ├─ Einfach (1 Ursache, 1 Systemebene)
    │   → Implementer erneut spawnen mit Fehler-Details (max 2x)
    │   → Wenn 2. Versuch fehlschlägt → Planner (Opus) = PFLICHT
    │
    ├─ Komplex (2+ Ursachen ODER 2+ Systemebenen)
    │   → Planner (Opus) spawnen = PFLICHT
    │   → Opus erstellt Sub-Issues (= Mini Phase I)
    │   → Orchestrator arbeitet Sub-Issues nacheinander ab
    │
    └─ Ursache unklar
        → Planner (Opus) spawnen = PFLICHT
        → Kein weiteres Probieren durch Orchestrator

Max 2 Testversuche. Danach Opus, egal was.
```

## Test-Nachweis (PFLICHT bei jedem Test)

Jeder durchgeführte Test wird dokumentiert:

```
TEST-NACHWEIS Issue #X:
- Was getestet: [konkrete Funktion/Verhalten]
- Wie getestet: [exakter Befehl, Eingabe oder Aktion]
- Ergebnis: [was beobachtet wurde]
- Status: BESTANDEN / NICHT BESTANDEN
```

Ohne Test-Nachweis darf kein Issue als abgeschlossen gelten.

## Abgleich mit projekt.md (nach jedem abgeschlossenen Issue)
- Orchestrator prüft: Stimmt die Umsetzung noch mit dem Opus-Plan überein?
- Falls Abweichung → Planner (Opus) spawnen für Korrektur der `projekt.md`
- Falls plangemäß → nächstes Issue beginnen

## Bei Problemen innerhalb eines Issues
- Wenn ein Issue mehr als 2 unabhängige Ursachen hat ODER mehr als eine Systemebene betrifft → Sub-Issues erstellen
- Sub-Issues im Kanban dokumentieren
- Opus-Wechsel vorschlagen (Claude Code schlägt vor, Ruben entscheidet)
