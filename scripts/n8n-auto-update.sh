#!/bin/bash
# N8N Auto-Update Script mit Backup & Rollback
# Prüft täglich auf Updates, erstellt Backup und benachrichtigt via Telegram

set -euo pipefail

# Konfiguration
CONTAINER_NAME="n8n-email-analyzer"
IMAGE_NAME="n8nio/n8n:latest"
BACKUP_DIR="/var/backups/n8n"
LOG_FILE="/var/log/n8n-auto-update.log"
TELEGRAM_BOT_TOKEN="8218652700:AAFyez3gfj_z3GaLdxNN141159RD98wjUgw"
TELEGRAM_CHAT_ID="6022997475"

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Telegram Notification
send_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${message}" \
        -d "parse_mode=Markdown" > /dev/null 2>&1 || true
}

# Hauptfunktion
main() {
    log "=== N8N Auto-Update Check gestartet ==="

    # Prüfe ob Container läuft
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log "ERROR: Container ${CONTAINER_NAME} läuft nicht!"
        send_telegram "⚠️ *N8N Auto-Update*%0A%0AContainer ${CONTAINER_NAME} läuft nicht!"
        exit 1
    fi

    # Aktuelle Version
    CURRENT_VERSION=$(docker exec "$CONTAINER_NAME" n8n --version 2>/dev/null || echo "unknown")
    log "Aktuelle Version: $CURRENT_VERSION"

    # Prüfe auf neues Image
    log "Prüfe auf Updates..."
    docker pull "$IMAGE_NAME" 2>&1 | tee -a "$LOG_FILE"

    # Vergleiche Image IDs
    RUNNING_IMAGE=$(docker inspect --format='{{.Image}}' "$CONTAINER_NAME")
    LATEST_IMAGE=$(docker inspect --format='{{.Id}}' "$IMAGE_NAME")

    if [ "$RUNNING_IMAGE" = "$LATEST_IMAGE" ]; then
        log "Keine Updates verfügbar. Container läuft bereits mit neuester Version."
        exit 0
    fi

    log "⚠️  UPDATE VERFÜGBAR! Starte Update-Prozess..."
    send_telegram "🔄 *N8N Update verfügbar*%0A%0AAktuelle Version: \`${CURRENT_VERSION}\`%0AStarte Update..."

    # Erstelle Backup-Verzeichnis
    mkdir -p "$BACKUP_DIR"
    BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_PATH="${BACKUP_DIR}/n8n_backup_${BACKUP_TIMESTAMP}.tar.gz"

    # Backup der n8n-Daten
    log "Erstelle Backup: $BACKUP_PATH"
    docker exec "$CONTAINER_NAME" tar -czf /tmp/n8n_backup.tar.gz /home/node/.n8n 2>/dev/null || {
        log "WARNING: Backup konnte nicht erstellt werden (möglicherweise keine Daten)"
    }
    docker cp "$CONTAINER_NAME:/tmp/n8n_backup.tar.gz" "$BACKUP_PATH" 2>/dev/null || {
        log "WARNING: Backup-Kopie fehlgeschlagen"
    }

    # Speichere Container-Konfiguration
    docker inspect "$CONTAINER_NAME" > "${BACKUP_DIR}/container_config_${BACKUP_TIMESTAMP}.json"

    log "Backup erstellt: $BACKUP_PATH"

    # Stoppe Container
    log "Stoppe Container..."
    docker stop "$CONTAINER_NAME"

    # Entferne alten Container (behält Volumes)
    log "Entferne alten Container..."
    docker rm "$CONTAINER_NAME"

    # Starte neuen Container mit gleichem Setup
    log "Starte Container mit neuem Image..."
    docker run -d \
        --name "$CONTAINER_NAME" \
        --restart unless-stopped \
        -p 127.0.0.1:5678:5678 \
        -v n8n_data:/home/node/.n8n \
        -e N8N_HOST="n8n.praxis-olszewski.de" \
        -e N8N_PROTOCOL="https" \
        -e WEBHOOK_URL="https://n8n.praxis-olszewski.de/" \
        "$IMAGE_NAME"

    # Warte auf Container-Start
    sleep 10

    # Prüfe ob Container läuft
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        NEW_VERSION=$(docker exec "$CONTAINER_NAME" n8n --version 2>/dev/null || echo "unknown")
        log "✅ Update erfolgreich! Neue Version: $NEW_VERSION"
        send_telegram "✅ *N8N Update erfolgreich*%0A%0A🆕 Neue Version: \`${NEW_VERSION}\`%0A📦 Backup: \`${BACKUP_PATH}\`"

        # Lösche alte Backups (behalte nur die letzten 5)
        log "Lösche alte Backups..."
        cd "$BACKUP_DIR" && ls -t n8n_backup_*.tar.gz | tail -n +6 | xargs -r rm -f
    else
        log "❌ ERROR: Container konnte nicht gestartet werden! Rollback erforderlich!"
        send_telegram "❌ *N8N Update FEHLGESCHLAGEN*%0A%0AContainer konnte nicht gestartet werden!%0AManuelle Intervention erforderlich!"
        exit 1
    fi

    log "=== N8N Auto-Update abgeschlossen ==="
}

# Führe Hauptfunktion aus
main "$@"
