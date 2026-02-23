# Server-Wartung Notizen

## Update-Workflow
1. Backup prüfen/erstellen (Pre-Update-Backup läuft jetzt automatisch)
2. `ssh hetzner "sudo apt update && sudo apt upgrade -y"`
3. Reboot falls nötig: `ssh hetzner "cat /var/run/reboot-required 2>/dev/null"`
4. Nach Reboot: Container + Website prüfen
5. Telegram-Monitoring meldet Status

## Cron-Übersicht (bernd)
- Soziotherapie-Alerts: alle 2h + 08:00 + Mo 09:00
- Security-Monitor: alle 15 Min
- Tägliches Backup: 02:00
- Telegram-Monitoring: System 08:00, Backup 09:00, Webapp alle 30min, Updates alle 6h
- Auto-Updates: Sonntag 04:00 (mit Pre-Update-Backup)

## Häufige Probleme
- **SCP Windows→Linux:** Immer `sed -i 's/\r//'` nach Upload (Windows-Zeilenumbrüche)
- **Docker-Updates:** Nicht automatisch - manuell oder über Sonntags-Cron
- **Reboot-Required:** Kernel-Updates lösen Telegram-Warnung aus → Reboot nötig
