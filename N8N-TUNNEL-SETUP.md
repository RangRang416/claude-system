# N8N SSH Tunnel Setup - Dokumentation

**Erstellt:** 2026-01-14
**Status:** ✅ Produktiv

---

## 📋 Überblick

Das n8n-System auf dem Hetzner-Server ist nur lokal erreichbar (localhost:5678). Um von Claude Desktop (Windows/WSL) darauf zuzugreifen, wird ein SSH-Tunnel verwendet.

---

## 🔧 Komponenten

### 1. SSH-Tunnel
- **Quelle:** localhost:5678 (WSL)
- **Ziel:** hetzner:localhost:5678
- **Protokoll:** SSH Port-Forwarding
- **Keep-Alive:** 60s Interval, 3 max retries

### 2. Tunnel Manager Script
**Pfad:** `/root/.claude/scripts/n8n-tunnel-manager.sh`

**Funktionen:**
```bash
# Tunnel starten
/root/.claude/scripts/n8n-tunnel-manager.sh start

# Status prüfen
/root/.claude/scripts/n8n-tunnel-manager.sh status

# Tunnel stoppen
/root/.claude/scripts/n8n-tunnel-manager.sh stop

# Tunnel neu starten
/root/.claude/scripts/n8n-tunnel-manager.sh restart
```

**Features:**
- ✅ Automatische PID-Verwaltung (`/tmp/n8n-tunnel.pid`)
- ✅ Logging (`/tmp/n8n-tunnel.log`)
- ✅ Health-Check (prüft n8n-Erreichbarkeit)
- ✅ Idempotent (mehrfacher Start-Aufruf sicher)

### 3. Auto-Start bei WSL-Login
**Pfad:** `/root/.bashrc` (Zeilen 101-104)

Der Tunnel wird automatisch gestartet wenn:
- Eine neue WSL-Shell geöffnet wird
- Claude Desktop startet (via MCP-Server)

---

## 🔑 API-Zugriff

### API-Key Location
- **Claude Desktop Config:** `/mnt/c/Users/Ruben/AppData/Roaming/Claude/claude_desktop_config.json`
- **Backup:** `~/.claude/secrets/n8n-api-key`

### Aktueller API-Key (Stand: 2026-01-14)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjNjE4NjI4Yy0wZTljLTRmMDMtOGQxNC0yYjc0MWVhMDEzOGUiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY4Mzk4Mjg0fQ.bkhJ47i2FjUoJTyZRBHJSP1MUCFqV6i1J9fOSc6z0lw
```

### MCP-Server Konfiguration
```json
{
  "mcp-n8n": {
    "command": "npx",
    "args": ["-y", "mcp-n8n"],
    "env": {
      "N8N_API_KEY": "<siehe oben>",
      "N8N_BASE_URL": "http://localhost:5678"
    }
  }
}
```

---

## ✅ Testing

### 1. Tunnel-Status prüfen
```bash
/root/.claude/scripts/n8n-tunnel-manager.sh status
```

**Erwartete Ausgabe:**
```
✅ N8N Tunnel is RUNNING (PID: XXXX)
✅ N8N is REACHABLE via tunnel
```

### 2. Direkte API-Anfrage
```bash
curl -s http://localhost:5678/healthz
# Output: {"status":"ok"}
```

### 3. Authentifizierte API-Anfrage
```bash
curl -s -H "X-N8N-API-KEY: <api-key>" \
  http://localhost:5678/api/v1/workflows \
  | python3 -m json.tool | head -20
```

### 4. MCP-Tools testen (nach Claude Desktop Neustart)
In Claude Desktop:
```
Kannst du die n8n-Workflows auflisten?
```

---

## 🔧 Troubleshooting

### Problem: Tunnel läuft nicht
**Lösung:**
```bash
/root/.claude/scripts/n8n-tunnel-manager.sh restart
```

### Problem: n8n nicht erreichbar via Tunnel
**Diagnose:**
```bash
# 1. Prüfe ob Tunnel läuft
ps aux | grep "ssh.*5678"

# 2. Prüfe n8n auf Server
ssh hetzner "curl -s http://localhost:5678/healthz"

# 3. Prüfe n8n Container
ssh hetzner "sudo docker ps | grep n8n"
ssh hetzner "sudo docker logs n8n-email-analyzer --tail 20"
```

### Problem: API-Key ungültig
**Symptom:** `{"message": "unauthorized"}`

**Lösung:**
1. Neuen API-Key in n8n erstellen:
   - https://n8n.praxis-olszewski.de → Settings → API Keys

2. Key in Claude Desktop Config aktualisieren:
   ```bash
   nano /mnt/c/Users/Ruben/AppData/Roaming/Claude/claude_desktop_config.json
   ```

3. Key in Secrets speichern:
   ```bash
   echo "NEUER_KEY" > ~/.claude/secrets/n8n-api-key
   ```

4. **Claude Desktop neu starten!**

### Problem: MCP-Tools funktionieren nicht
**Checkliste:**
- [ ] Tunnel läuft: `/root/.claude/scripts/n8n-tunnel-manager.sh status`
- [ ] API-Key korrekt in Config: `cat /mnt/c/Users/Ruben/AppData/Roaming/Claude/claude_desktop_config.json | grep N8N_API_KEY`
- [ ] Claude Desktop neu gestartet nach Config-Änderung
- [ ] n8n-Server läuft: `ssh hetzner "sudo docker ps | grep n8n"`

---

## 🚨 Wichtige Hinweise

### API-Key-Updates
⚠️ **Nach jedem API-Key-Update:**
1. Config-Datei aktualisieren
2. **Claude Desktop neu starten** (wichtig!)
3. Tunnel-Status prüfen

### Shell-Crash-Problem (behoben)
**Problem:** curl-Befehle über SSH haben Shell zum Absturz gebracht

**Ursache:** Direkte curl-Befehle über SSH-Tunnel ohne Timeout/Output-Limit

**Lösung:**
- Tunnel-Manager nutzt robuste SSH-Tunnel mit Keep-Alive
- API-Anfragen laufen über etablierten Tunnel (nicht über SSH-Befehl)
- Timeouts und Output-Limits bei allen curl-Befehlen

### Sicherheit
- ✅ n8n ist NICHT öffentlich exponiert (nur localhost)
- ✅ Zugriff nur via SSH-Tunnel (mit Key-Auth)
- ✅ API-Key gespeichert in lokalem Config (nicht in Git)

---

## 📊 Status-Übersicht

| Komponente | Status | Version |
|------------|--------|---------|
| n8n Server | ✅ Running | 2.3.4 |
| SSH Tunnel | ✅ Active | - |
| Auto-Start | ✅ Configured | - |
| MCP-Tools | ⏳ Benötigt Neustart | - |
| API-Zugriff | ✅ Funktioniert | - |

---

## 🔗 Verwandte Dokumentation

- **n8n-Zugang:** `/mnt/c/Users/Ruben/.claude/Hetzner-Server/n8n-email-analyzer/N8N-ZUGANG-CLAUDE-CODE.md`
- **Email Analyzer Projekt:** `/mnt/c/Users/Ruben/.claude/Hetzner-Server/n8n-email-analyzer/N8N-EMAIL-ANALYSE-PROJEKT.md`
- **Server-Dokumentation:** `/root/.claude/CLAUDE.md`

---

**🤖 Automatisch erstellt von Claude Code - 2026-01-14**
