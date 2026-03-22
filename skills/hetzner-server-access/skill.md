# Hetzner Server Access Skill (Global)

**Typ:** Globaler Skill - verfügbar in allen Claude Code Sessions
**Server:** CX23 (46.224.220.236:2222) - Downgrade von CPX22 am 16.01.2026

---

## 🎯 Wann wird dieser Skill aktiviert?

Erkannte Trigger-Wörter:
- "Server", "Hetzner", "praxis-olszewski"
- "SSH", "Server-Verbindung", "Server-Zugang"
- "Server-Status", "Server prüfen", "Logs"
- "Apache", "Docker", "N8N"
- "Deploy", "Deployment", "auf Server laden"

---

## 🔧 SSH-Zugang (bereits konfiguriert)

### Schneller Zugang via Alias
```bash
ssh hetzner
```

**Vollständiger Befehl:**
```bash
ssh -i ~/.ssh/bernd_ed25519 -p 2222 bernd@46.224.220.236
```

**SSH-Config** (`~/.ssh/config`):
```
Host hetzner
    HostName 46.224.220.236
    Port 2222
    User bernd
    IdentityFile ~/.ssh/bernd_ed25519
    StrictHostKeyChecking no
    ServerAliveInterval 60
```

---

## 📊 Server-Ressourcen

| Ressource | Gesamt | Genutzt | Verfügbar | Status |
|-----------|--------|---------|-----------|---------|
| **RAM** | 3.7 GB | ~650 MB (17%) | 3.1 GB | ✅ Ausreichend |
| **Disk** | 38 GB | 3.7 GB (11%) | 33 GB | ✅ Viel Platz |
| **CPU** | 2 Cores | ~10% | - | ✅ Wenig Last |

**Kapazitäten für neue Services:** ✅ Mehr als genug für N8N, APIs, etc.

---

## 🌐 Laufende Anwendungen

### 1. Öffentliche Praxis-Website
- **URL:** https://praxis-olszewski.de/
- **Pfad:** `/var/www/praxis-olszewski` (5 MB)
- **Status:** ✅ Produktiv

### 2. Soziotherapie-Abrechnungsapp (AKTIV)
- **URL:** https://praxis-olszewski.de/soziotherapie/
- **Pfad:** `/var/www/soziotherapie` (4.4 MB)
- **DB:** SQLite (88 KB)
- **Technologie:** PHP 8.3.6 + SQLite
- **Features:**
  - Patientenverwaltung
  - Verordnungen & Termine
  - Telegram-Alerts (Cron)
  - Auto-Backups (täglich 2:00)

### 3. N8N Workflow Automation ⚡ NEU
- **URL:** http://127.0.0.1:5678 (lokal)
- **Container:** `n8n-email-analyzer`
- **Technologie:** Docker (n8nio/n8n:latest)
- **Projekt:** Email-Analyse mit Claude AI

### 4. Zettelkasten API
- **URL:** http://127.0.0.1:8501 (lokal)
- **Technologie:** Python/uvicorn

### 5. Telegram Monitoring
- **Bot:** @Hetznit_bot
- **Token:** `${TELEGRAM_BOT_TOKEN}`
- **Chat ID:** `6022997475`
- **Checks:** Security, System, Backup, Web-App, SSL, Updates
- **Auto-Updates:** ✅ Ubuntu-Pakete (automatisch), ⚠️ Docker/Node.js (manuell)

---

## 🚀 Häufige Befehle

### System-Status
```bash
# Kompakt
ssh hetzner "uptime && free -h && df -h /"

# Ausführlich
ssh hetzner "uptime && free -h && df -h && docker ps"
```

### Apache
```bash
# Status
ssh hetzner "sudo systemctl status apache2"

# VirtualHosts anzeigen
ssh hetzner "sudo apachectl -S"

# Neustart
ssh hetzner "sudo systemctl restart apache2"

# Config-Test
ssh hetzner "sudo apachectl configtest"
```

### Logs
```bash
# Apache Error Log (live)
ssh hetzner "sudo tail -f /var/log/apache2/error.log"

# Apache Access Log (letzte 50)
ssh hetzner "sudo tail -50 /var/log/apache2/access.log"

# Telegram Monitoring
ssh hetzner "tail -f /var/log/telegram-monitoring.log"

# Auth-Log (SSH-Versuche)
ssh hetzner "sudo tail -50 /var/log/auth.log"
```

### Docker
```bash
# Container-Status
ssh hetzner "docker ps -a"

# Container starten/stoppen
ssh hetzner "docker start <container>"
ssh hetzner "docker stop <container>"

# Logs
ssh hetzner "docker logs -f <container>"

# N8N (wenn installiert)
ssh hetzner "docker logs -f n8n"
```

### Backups
```bash
# Soziotherapie DB-Backup
ssh hetzner "sudo cp /var/www/soziotherapie/soziotherapie.db /var/backups/soziotherapie/backup_\$(date +%Y%m%d_%H%M%S).db"

# Backup-Liste
ssh hetzner "ls -lh /var/backups/soziotherapie/"
```

### Cron-Jobs
```bash
# Anzeigen
ssh hetzner "crontab -l"

# Bearbeiten
ssh hetzner "crontab -e"
```

---

## 📤 Deployment-Workflows

### Einzelne Datei deployen
```bash
# 1. Datei zum Server kopieren
scp -P 2222 /local/file.php bernd@46.224.220.236:/tmp/

# 2. Verschieben & Rechte setzen
ssh hetzner "sudo cp /tmp/file.php /var/www/soziotherapie/ && \
             sudo chown www-data:www-data /var/www/soziotherapie/file.php"
```

### Verzeichnis synchronisieren
```bash
# rsync (effizienter für mehrere Dateien)
rsync -avz -e "ssh -p 2222" \
  /local/dir/ \
  bernd@46.224.220.236:/tmp/deploy/

ssh hetzner "sudo rsync -av /tmp/deploy/ /var/www/soziotherapie/ && \
             sudo chown -R www-data:www-data /var/www/soziotherapie/"
```

---

## 📂 Wichtige Server-Pfade

### Webanwendungen
| App | Pfad |
|-----|------|
| Praxis-Website | `/var/www/praxis-olszewski` |
| Soziotherapie | `/var/www/soziotherapie` |
| Soziotherapie DB | `/var/www/soziotherapie/soziotherapie.db` |

### Logs
| Log | Pfad |
|-----|------|
| Apache Error | `/var/log/apache2/error.log` |
| Apache Access | `/var/log/apache2/access.log` |
| Auth (SSH) | `/var/log/auth.log` |
| Telegram Monitor | `/var/log/telegram-monitoring.log` |
| Sozio-Logs | `/home/bernd/logs/` |

### Konfiguration
| Config | Pfad |
|--------|------|
| Apache Sites | `/etc/apache2/sites-available/` |
| Apache Enabled | `/etc/apache2/sites-enabled/` |
| Apache Main | `/etc/apache2/apache2.conf` |

### Backups
| Backup | Pfad |
|--------|------|
| Soziotherapie | `/var/backups/soziotherapie/` |

---

## 🔐 Sicherheit

### Sudo-Rechte
- User `bernd` hat sudo-Rechte
- **Passwortlos sudo ist NICHT aktiviert**
- Interaktive Eingabe nötig bei sudo-Befehlen

### SSH-Key Berechtigungen
```bash
# Falls "Permission denied (publickey)" Fehler:
chmod 600 ~/.ssh/bernd_ed25519
```

### Firewall (UFW)
Offene Ports:
- **2222:** SSH
- **80:** HTTP (→ HTTPS Redirect)
- **443:** HTTPS
- **8443:** HTTPS Alternative

---

## 🔧 Troubleshooting

### Problem: SSH-Verbindung fehlschlägt
```bash
# Verbose-Modus für Debugging
ssh -v hetzner

# Key-Berechtigungen prüfen
ls -l ~/.ssh/bernd_ed25519  # Sollte -rw------- sein
chmod 600 ~/.ssh/bernd_ed25519
```

### Problem: Apache startet nicht
```bash
# Config-Syntax testen
ssh hetzner "sudo apachectl configtest"

# Fehler-Log prüfen
ssh hetzner "sudo tail -50 /var/log/apache2/error.log"

# Apache-Status
ssh hetzner "sudo systemctl status apache2"
```

### Problem: Disk voll
```bash
# Größte Verzeichnisse finden
ssh hetzner "sudo du -h /var | sort -rh | head -20"

# Alte Logs löschen
ssh hetzner "sudo journalctl --vacuum-size=500M"

# Alte Backups bereinigen
ssh hetzner "sudo find /var/backups -type f -mtime +30 -delete"
```

### Problem: Docker Container läuft nicht
```bash
# Container-Status
ssh hetzner "docker ps -a"

# Logs prüfen
ssh hetzner "docker logs <container>"

# Container neu starten
ssh hetzner "docker restart <container>"
```

---

## 🎯 Skill-Aktionen

### Automatische Aktionen bei Trigger:

#### "Server-Status"
→ Führt aus: `ssh hetzner "uptime && free -h && df -h && docker ps"`

#### "Logs anzeigen"
→ Fragt: "Welches Log?" → Apache Error / Access / Telegram / Auth
→ Führt aus: `ssh hetzner "sudo tail -f /var/log/..."`

#### "Backup erstellen"
→ Fragt: "Was sichern?" → Soziotherapie DB / Komplettes Verzeichnis
→ Führt aus: Backup-Befehl mit Timestamp

#### "Deployment"
→ Fragt: "Welche Dateien?" → Einzelne Datei / Verzeichnis
→ Führt aus: scp/rsync + chown

#### "Docker"
→ Fragt: "Was tun?" → Status / Logs / Start / Stop
→ Führt aus: docker-Befehle

---

## 📚 Weiterführende Dokumentation

- **Detaillierte Kapazitäten:** `SERVER-KAPAZITAETEN-ANALYSE.md`
- **N8N-Projekt:** `N8N-EMAIL-ANALYSE-PROJEKT.md`
- **Telegram Monitoring:** `TELEGRAM_MONITORING_README.md` (in HetznerMCP/)

---

**🤖 Version:** 1.1
**Erstellt:** 2025-10-23
**Aktualisiert:** 2026-01-25
**Typ:** Global Skill

---

## ⚡ Changelog

### Version 1.1 (2026-01-25)
- ✅ Server-IP aktualisiert auf 46.224.220.236 (CX23)
- ✅ N8N Workflow Automation hinzugefügt
- ✅ Auto-Update-Konfiguration dokumentiert
- ✅ Telegram Monitoring erweitert (manuelle vs. automatische Updates)
