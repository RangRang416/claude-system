#!/bin/bash
# Pre-Update Backup Script
# Erstellt automatisch Backups vor apt-Updates und Reboots

BACKUP_DIR="/var/backups/pre-update-$(date +%Y%m%d-%H%M)"
LOG="/var/log/pre-update-backup.log"

echo "[$(date)] Pre-Update Backup gestartet" >> "$LOG"

mkdir -p "$BACKUP_DIR"

# Soziotherapie DB
cp /var/www/soziotherapie/soziotherapie.db "$BACKUP_DIR/" 2>/dev/null
cp /var/www/soziotherapie/data/app.db "$BACKUP_DIR/" 2>/dev/null

# Vorgangs-Manager DB + Uploads
cp /var/www/vorgaenge/data/vorgaenge.db "$BACKUP_DIR/" 2>/dev/null
tar czf "$BACKUP_DIR/vorgaenge_uploads.tar.gz" -C /var/www/vorgaenge/uploads . 2>/dev/null

# N8N Data Volume
docker run --rm -v n8n_n8n_data:/data -v "$BACKUP_DIR":/backup alpine tar czf /backup/n8n_data.tar.gz -C /data . 2>/dev/null

# Cleanup: Nur die letzten 3 Backups behalten
ls -dt /var/backups/pre-update-* 2>/dev/null | tail -n +4 | xargs rm -rf

echo "[$(date)] Backup erstellt: $BACKUP_DIR" >> "$LOG"
ls -lh "$BACKUP_DIR" >> "$LOG"
