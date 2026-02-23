# Verbindlicher Projekt-Workflow

**Gilt für JEDES neue Projekt und JEDE größere Aufgabe.**

---

## Phase 0: Projekt-Setup

Bevor eine einzige Zeile Code geschrieben wird:

1. **Repo erstellen** (falls nicht vorhanden)
   - README.md mit Projektbeschreibung
   - .gitignore
   - CHANGELOG.md (leer, mit Struktur)

2. **Kritischste Annahme identifizieren** (PFLICHT!)
   - Was ist die Kern-Funktion, ohne die das Projekt sinnlos ist?
   - **Diese Funktion ZUERST als Proof-of-Concept testen**
   - Wenn der PoC scheitert → STOP, Alternativen suchen, nicht weiterbauen
   - Beispiel N8N: PDF-Texterkennung war kritisch → hätte zuerst getestet werden müssen

3. **Projektplan erstellen** (als GitHub Issues oder PLAN.md)
   - Was ist das Ziel?
   - Welche Schritte sind nötig?
   - Welche Abhängigkeiten gibt es?
   - Was muss Ruben entscheiden/liefern?

4. **Mindmap erstellen** (in `claude-projekt/mindmaps/`)
   - Visueller Überblick für Ruben
   - Wird gemeinsam besprochen und von Claude aktualisiert

5. **Ruben den Plan vorlegen**
   - Zusammenfassung in verständlicher Sprache
   - Rückfragen klären BEVOR Umsetzung beginnt

---

## Phase 1: Planung (Issues/Tasks)

Jedes Projekt wird in **einzelne, abgeschlossene Schritte** zerlegt:

```
Issue #1: Grundstruktur aufsetzen
Issue #2: [Kern-Feature A] ← blockiert durch #1
Issue #3: [Kern-Feature B] ← blockiert durch #1
Issue #4: Integration A+B  ← blockiert durch #2 und #3
Issue #5: Testing & Evaluation ← blockiert durch #4
Issue #6: Dokumentation & Deployment ← blockiert durch #5
```

Jedes Issue hat:
- **Klare Beschreibung:** Was genau wird gemacht?
- **Abnahme-Kriterien:** Wann ist der Schritt fertig?
- **Abhängigkeiten:** Was muss vorher erledigt sein?

---

## Phase 2: Umsetzung (Schritt für Schritt)

**Reihenfolge ist BINDEND.** Kein Schritt wird begonnen bevor der vorherige abgeschlossen ist.

Für jeden Schritt:

```
1. Issue öffnen / Status: "In Progress"
2. Implementieren
3. Testen (funktioniert es?)
4. Commit mit Verweis auf Issue
5. Kurze Rückmeldung an Ruben: "Schritt X fertig, Ergebnis: ..."
6. Issue schließen (mit Rückfrage)
7. → Nächster Schritt
```

### Was "fertig" bedeutet:
- ✅ Code funktioniert (getestet)
- ✅ Keine offenen Fehler
- ✅ Commit gemacht
- ✅ CHANGELOG aktualisiert (wenn relevant)

### Was "fertig" NICHT bedeutet:
- ❌ "Sollte funktionieren" (nicht getestet)
- ❌ "Grundgerüst steht" (halb fertig)
- ❌ Weiter zum nächsten Schritt trotz Fehlern

---

## Phase 3: Evaluation & Debugging

Dies ist ein **eigener, expliziter Schritt** - kein Nachgedanke.

1. **Funktionstest:** Tut die Anwendung was sie soll?
2. **Fehlersuche:** Systematisch, nicht zufällig
   - Was genau funktioniert nicht?
   - Wo liegt die Ursache?
   - Fix implementieren → erneut testen
3. **Ruben-Test:** Ruben testet aus User-Sicht
   - Feedback einarbeiten
   - Erneut testen

---

## Phase 4: Dokumentation & Abschluss

1. README.md finalisieren
2. CHANGELOG.md aktualisieren
3. PROJECT-OVERVIEW.md aktualisieren
4. MEMORY.md aktualisieren (Projekt-Status)
5. Commit + Push-Frage

---

## Anti-Patterns (was NICHT passieren darf)

| Anti-Pattern | Stattdessen |
|-------------|-------------|
| Sofort coden ohne Plan | Erst planen, dann umsetzen |
| Nebensache zuerst bauen, Kernfunktion zuletzt | Kritischste Funktion ZUERST als PoC testen |
| Alles auf einmal bauen | Schritt für Schritt mit Tests |
| Fehler ignorieren, weitermachen | Erst fixen, dann nächster Schritt |
| "Funktioniert wahrscheinlich" | Testen und beweisen |
| Dokumentation vergessen | Ist Teil jedes Schritts |
| Ruben mit Code-Details belasten | Status-Updates in klarer Sprache |

---

## Wann gilt dieser Workflow?

- **Neues Projekt:** Immer komplett (Phase 0-4)
- **Neues Feature in bestehendem Projekt:** Ab Phase 1
- **Bugfix:** Phase 2 (Implementierung + Test) + Dokumentation
- **Server-Wartung:** Dokumentation (CHANGELOG + MEMORY)
