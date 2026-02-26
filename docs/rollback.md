# Rollback-Strategie

| Situation | Maßnahme |
|-----------|----------|
| Test schlägt fehl, Ursache klar | Fix implementieren, erneut testen |
| Test schlägt fehl, Ursache unklar | Sub-Issues erstellen, Opus vorschlagen |
| Umsetzung grundsätzlich falsch | `git revert` auf letzten stabilen Commit |
| Branch komplett gescheitert | Branch verwerfen, neu von stabilem Stand |
| Kein stabiler Stand vorhanden | Ruben informieren, gemeinsam entscheiden |

**Rollback nie stillschweigend.** Immer Ruben informieren mit: was revertiert wurde und warum.
