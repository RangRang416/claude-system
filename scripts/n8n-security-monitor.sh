#!/bin/bash
# N8N Security Monitoring Script
# Überwacht n8n-Sicherheit und sendet Alerts bei Anomalien

set -euo pipefail

# Konfiguration
CONTAINER_NAME="n8n-email-analyzer"
LOG_FILE="/var/log/n8n-security-monitor.log"
TELEGRAM_BOT_TOKEN="8218652700:AAFyez3gfj_z3GaLdxNN141159RD98wjUgw"
TELEGRAM_CHAT_ID="6022997475"
STATE_DIR="/var/lib/n8n-monitor"
ALERT_COOLDOWN=3600  # Sekunden zwischen gleichen Alerts

# Farben für Logging
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Erstelle State-Verzeichnis
mkdir -p "$STATE_DIR"

# Logging
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

# Telegram Alert
send_alert() {
    local severity="$1"  # 🔴 CRITICAL, 🟠 WARNING, 🟢 INFO
    local title="$2"
    local message="$3"

    # Prüfe Alert-Cooldown
    local alert_hash=$(echo "$title" | md5sum | cut -d' ' -f1)
    local last_alert_file="$STATE_DIR/alert_${alert_hash}"

    if [ -f "$last_alert_file" ]; then
        local last_alert=$(cat "$last_alert_file")
        local now=$(date +%s)
        local diff=$((now - last_alert))

        if [ $diff -lt $ALERT_COOLDOWN ]; then
            log "DEBUG" "Alert cooldown active for '$title' (${diff}s/${ALERT_COOLDOWN}s)"
            return 0
        fi
    fi

    # Sende Alert
    local full_message="${severity} *N8N Security Alert*%0A%0A*${title}*%0A%0A${message}"

    if curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=${full_message}" \
        -d "parse_mode=Markdown" > /dev/null 2>&1; then

        log "INFO" "Alert sent: $title"
        date +%s > "$last_alert_file"
    else
        log "ERROR" "Failed to send alert: $title"
    fi
}

# 1. N8N Container Status prüfen
check_n8n_container() {
    log "INFO" "Checking n8n container status..."

    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log "ERROR" "n8n container is NOT running!"
        send_alert "🔴 CRITICAL" "N8N Container Down" \
            "Der n8n-Container ist nicht aktiv!%0A%0AManuelle Intervention erforderlich."
        return 1
    fi

    # Prüfe Container-Health
    local status=$(docker inspect --format='{{.State.Status}}' "$CONTAINER_NAME")
    local health=$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "unknown")

    if [ "$status" != "running" ]; then
        log "ERROR" "n8n container status: $status"
        send_alert "🔴 CRITICAL" "N8N Container Status" \
            "Container-Status: \`${status}\`%0A%0ANicht im Running-Zustand!"
        return 1
    fi

    log "INFO" "n8n container is running (health: $health)"
    return 0
}

# 2. N8N Version prüfen
check_n8n_version() {
    log "INFO" "Checking n8n version..."

    local current_version=$(docker exec "$CONTAINER_NAME" n8n --version 2>/dev/null || echo "unknown")
    local version_file="$STATE_DIR/n8n_version"

    # Speichere aktuelle Version
    if [ ! -f "$version_file" ]; then
        echo "$current_version" > "$version_file"
        log "INFO" "Initial n8n version recorded: $current_version"
        return 0
    fi

    local stored_version=$(cat "$version_file")

    # Prüfe auf Downgrade (verdächtig!)
    if [ "$current_version" != "$stored_version" ]; then
        local major_current=$(echo "$current_version" | cut -d. -f1)
        local major_stored=$(echo "$stored_version" | cut -d. -f1)

        if [ "$major_current" -lt "$major_stored" ]; then
            log "ERROR" "Version DOWNGRADE detected! $stored_version -> $current_version"
            send_alert "🔴 CRITICAL" "N8N Version Downgrade" \
                "Version wurde zurückgestuft!%0A%0AAlt: \`${stored_version}\`%0ANeu: \`${current_version}\`%0A%0AMögliche Kompromittierung!"
        else
            log "INFO" "Version change: $stored_version -> $current_version"
            send_alert "🟢 INFO" "N8N Version Update" \
                "Version wurde aktualisiert:%0A%0AAlt: \`${stored_version}\`%0ANeu: \`${current_version}\`"
        fi

        echo "$current_version" > "$version_file"
    fi

    return 0
}

# 3. Verdächtige Login-Versuche prüfen
check_suspicious_logins() {
    log "INFO" "Checking for suspicious login attempts..."

    local npm_log="/var/lib/docker/volumes/nginx-proxy-manager_data/_data/logs/proxy-host-1_access.log"
    local check_file="$STATE_DIR/last_login_check"
    local now=$(date +%s)

    # Finde NPM-Logs (Docker-Volume)
    if [ ! -f "$npm_log" ]; then
        # Fallback: Im Container suchen
        npm_log=$(docker exec nginx-proxy-manager find /data/logs -name 'proxy-host-1_access.log' 2>/dev/null || echo "")
    fi

    if [ -z "$npm_log" ] || [ ! -f "$npm_log" ]; then
        log "DEBUG" "NPM access log not found, skipping login check"
        return 0
    fi

    # Prüfe seit letztem Check
    local since_minutes=60
    if [ -f "$check_file" ]; then
        local last_check=$(cat "$check_file")
        since_minutes=$(( (now - last_check) / 60 ))
    fi

    # Zähle Failed Login-Versuche (401 auf /rest/login)
    local failed_logins=$(grep -c '401.*"/rest/login"' "$npm_log" 2>/dev/null || echo 0)

    if [ "$failed_logins" -gt 10 ]; then
        log "WARNING" "Multiple failed login attempts detected: $failed_logins"
        send_alert "🟠 WARNING" "Multiple Failed Logins" \
            "Anzahl fehlgeschlagener Login-Versuche: ${failed_logins}%0A%0AMöglicher Brute-Force-Angriff!"
    fi

    echo "$now" > "$check_file"
    return 0
}

# 4. Unerwartete Docker-Container prüfen
check_unexpected_containers() {
    log "INFO" "Checking for unexpected Docker containers..."

    local expected_containers="nginx-proxy-manager|n8n-email-analyzer|portainer|watchtower"
    local unexpected=$(docker ps --format '{{.Names}}' | grep -Ev "^($expected_containers)$" || echo "")

    if [ -n "$unexpected" ]; then
        log "WARNING" "Unexpected containers running: $unexpected"
        send_alert "🟠 WARNING" "Unerwartete Docker-Container" \
            "Folgende Container sollten nicht laufen:%0A%0A\`${unexpected}\`%0A%0ABitte prüfen!"
    fi

    return 0
}

# 5. Verdächtige Netzwerk-Verbindungen prüfen
check_suspicious_connections() {
    log "INFO" "Checking for suspicious network connections..."

    # Prüfe auf Verbindungen zu n8n-Port von außen (sollte nur localhost sein)
    local external_conns=$(netstat -tnp 2>/dev/null | grep ':5678' | grep -v '127.0.0.1' | wc -l)

    if [ "$external_conns" -gt 0 ]; then
        log "WARNING" "External connections to n8n port detected!"
        local conns=$(netstat -tnp 2>/dev/null | grep ':5678' | grep -v '127.0.0.1')
        send_alert "🟠 WARNING" "Externe n8n-Verbindungen" \
            "Externe Verbindungen zu Port 5678 erkannt!%0A%0A\`${conns}\`%0A%0ADies sollte nicht passieren!"
    fi

    return 0
}

# 6. Filesystem-Integrity prüfen (kritische n8n-Dateien)
check_filesystem_integrity() {
    log "INFO" "Checking filesystem integrity..."

    # Prüfe ob n8n-Binary im Container verändert wurde
    local binary_hash=$(docker exec "$CONTAINER_NAME" sha256sum /usr/local/bin/n8n 2>/dev/null | cut -d' ' -f1 || echo "unknown")
    local hash_file="$STATE_DIR/n8n_binary_hash"

    if [ ! -f "$hash_file" ]; then
        echo "$binary_hash" > "$hash_file"
        log "INFO" "Initial n8n binary hash recorded"
        return 0
    fi

    local stored_hash=$(cat "$hash_file")

    if [ "$binary_hash" != "$stored_hash" ] && [ "$binary_hash" != "unknown" ]; then
        log "ERROR" "n8n binary has been modified!"
        send_alert "🔴 CRITICAL" "N8N Binary Modified" \
            "Die n8n-Binary wurde verändert!%0A%0AHash alt: \`${stored_hash}\`%0AHash neu: \`${binary_hash}\`%0A%0A⚠️ Mögliche Kompromittierung!"
    fi

    return 0
}

# Hauptfunktion
main() {
    log "INFO" "=== N8N Security Monitor gestartet ==="

    local exit_code=0

    # Führe alle Checks durch
    check_n8n_container || exit_code=1
    check_n8n_version || exit_code=1
    check_suspicious_logins || exit_code=1
    check_unexpected_containers || exit_code=1
    check_suspicious_connections || exit_code=1
    check_filesystem_integrity || exit_code=1

    if [ $exit_code -eq 0 ]; then
        log "INFO" "All security checks passed ✓"
    else
        log "WARNING" "Some security checks failed!"
    fi

    log "INFO" "=== N8N Security Monitor abgeschlossen ==="

    return $exit_code
}

# Führe aus
main "$@"
