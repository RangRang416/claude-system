# 🚀 Claude Code Startup Guide

**Für neue Claude Code Sessions**

---

## ⚡ Sofort-Start: n8n-Zugriff aktivieren

Wenn du mit **n8n** arbeiten willst, führe **sofort** beim Start aus:

```bash
source /root/.claude/scripts/setup-n8n-tunnel.sh
```

Das war's! Du hast jetzt:
- ✅ SSH-Tunnel zu n8n (Hetzner → localhost:5678)
- ✅ API-Key geladen (`$N8N_API_KEY`)
- ✅ Helper-Funktionen verfügbar
- ✅ Alles getestet und funktioniert

---

## 📋 Was das Script macht

1. **SSH-Tunnel starten** (falls nicht läuft)
   - `localhost:5678` → `46.224.220.236:5678`
   - Im Hintergrund, mit KeepAlive

2. **n8n-Verbindung testen**
   - HTTP-Check auf `localhost:5678`

3. **API-Key laden**
   - Aus `~/.claude/secrets/n8n-api-key`
   - Als `$N8N_API_KEY` Umgebungsvariable

4. **Helper-Funktionen bereitstellen**
   - `n8n_list_workflows` - Workflows auflisten
   - `n8n_get_workflow <id>` - Workflow abrufen
   - `n8n_save_workflow <id> [file]` - Workflow speichern
   - `stop_n8n_tunnel` - Tunnel beenden

---

## 🎯 Häufige Aufgaben

### Workflows auflisten
```bash
n8n_list_workflows | grep '"name"'
```

### Workflow exportieren
```bash
n8n_save_workflow 3U4oaAs0M5WpZY6m /mnt/c/Users/Ruben/.claude/my-workflow.json
```

### Workflow über API bearbeiten
```bash
# 1. Workflow abrufen und speichern
n8n_save_workflow 3U4oaAs0M5WpZY6m workflow.json

# 2. Bearbeiten (mit Edit-Tool oder manuell)
# ... edit workflow.json ...

# 3. Zurück hochladen
curl -X PUT "http://localhost:5678/api/v1/workflows/3U4oaAs0M5WpZY6m" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -H "Content-Type: application/json" \
  -d @workflow.json
```

### Neuen Workflow erstellen
```bash
curl -X POST "http://localhost:5678/api/v1/workflows" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -H "Content-Type: application/json" \
  -d @new-workflow.json
```

---

## 🔧 Troubleshooting

### "Connection refused" Fehler

**Lösung:**
```bash
# 1. Tunnel neu starten
stop_n8n_tunnel
source /root/.claude/scripts/setup-n8n-tunnel.sh

# 2. n8n auf Server prüfen
ssh hetzner "docker ps | grep n8n"
```

### Tunnel läuft nicht mehr

**Lösung:**
```bash
source /root/.claude/scripts/setup-n8n-tunnel.sh
```

### API-Key ungültig

**Lösung:**
```bash
# Aktuellen Key prüfen
cat ~/.claude/secrets/n8n-api-key

# Wenn abgelaufen → Neuen Key in n8n-UI generieren
# Dann in ~/.claude/secrets/n8n-api-key speichern
```

---

## 📚 Weitere Dokumentation

- **Vollständige n8n-Doku:** `/mnt/c/Users/Ruben/.claude/N8N-ZUGANG-CLAUDE-CODE.md`
- **Ruben's Memory:** `/mnt/c/Users/Ruben/.claude/memory.md`
- **Server-Infos:** `/mnt/c/Users/Ruben/.claude/CLAUDE.md`

---

## ⚠️ Wichtige Hinweise

### Arbeitsverzeichnis
- **Immer arbeiten in:** `/mnt/c/Users/Ruben/...`
- **Niemals in:** `/root/` oder `/`
- **Grund:** Nur `/mnt/c/Users/Ruben/` ist in Windows sichtbar!

### Dateien speichern
```bash
# ✅ RICHTIG - Ruben sieht die Datei in Windows
/mnt/c/Users/Ruben/.claude/workflow.json

# ❌ FALSCH - Datei ist unsichtbar für Ruben
/root/workflow.json
```

### Claude Desktop vs. Claude Code
- **Claude Desktop:** n8n-MCP funktioniert NICHT (kein Tunnel)
- **Claude Code (DU!):** Perfekt für n8n-Workflows (mit Tunnel)

---

## ✅ Quick-Check beim Start

Führe beim Start aus:

```bash
# 1. n8n-Zugriff aktivieren
source /root/.claude/scripts/setup-n8n-tunnel.sh

# 2. Test durchführen
n8n_list_workflows | grep '"name"' | head -5

# 3. Arbeitsverzeichnis prüfen
pwd
# Sollte sein: /mnt/c/Users/Ruben (oder Unterordner)
```

Wenn alles funktioniert → **Du bist bereit!** 🚀

---

**Erstellt:** 2025-11-25
**Für:** Zukünftige Claude Code Instanzen
**Status:** ✅ Aktiv
