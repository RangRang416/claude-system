#!/bin/bash
# Comprehensive Server Security Monitoring
# Überwacht n8n UND den gesamten Server auf Sicherheitsprobleme

set -euo pipefail

# ============================================================================
# KONFIGURATION
# ============================================================================

# Server-Identifikation
SERVER_NAME="hetzner-ubuntu-4gb-hel1-2"
SERVER_IP="157.180.65.145"

# Telegram
TELEGRAM_BOT_TOKEN="8218652700:AAFyez3gfj_z3GaLdxNN141159RD98wjUgw"
TELEGRAM_CHAT_ID="6022997475"

# Monitoring-Konfiguration
LOG_FILE="/var/log/server-security-monitor.log"
STATE_DIR="/var/lib/server-monitor"
ALERT_COOLDOWN=3600  # 1 Stunde zwischen gleichen Alerts

# Schwellwerte
DISK_WARNING=80      # % - Warnung
DISK_CRITICAL=90     # % - Critical
RAM_WARNING=85       # %
CPU_WARNING=90       # %
SSH_FAILED_THRESHOLD=10  # Anzahl fehlgeschlagener SSH-Logins

# Container-Whitelist
EXPECTED_CONTAINERS="nginx-proxy-manager|n8n-email-analyzer|portainer"

# ============================================================================
# HELPER-FUNKTIONEN
# ============================================================================

# Farben
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# State-Verzeichnis erstellen
mkdir -p "$STATE_DIR"

# Logging
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

# Telegram Alert mit Cooldown
send_alert() {
    local severity="$1"  # 🔴 CRITICAL, 🟠 WARNING, 🟢 INFO
    local title="$2"
    local message="$3"

    # Alert-Cooldown prüfen
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
    local full_message="${severity} *Server Security Alert*%0A*${SERVER_NAME}*%0A%0A*${title}*%0A%0A${message}"

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

# ============================================================================
# N8N-SPEZIFISCHE CHECKS
# ============================================================================

check_n8n_container() {
    log "INFO" "Checking n8n container..."

    local container="n8n-email-analyzer"

    if ! docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        log "ERROR" "n8n container is NOT running!"
        send_alert "🔴 CRITICAL" "N8N Container Down" \
            "Der n8n-Container ist nicht aktiv!%0A%0AManuelle Intervention erforderlich."
        return 1
    fi

    local status=$(docker inspect --format='{{.State.Status}}' "$container")

    if [ "$status" != "running" ]; then
        log "ERROR" "n8n container status: $status"
        send_alert "🔴 CRITICAL" "N8N Container Status" \
            "Container-Status: \`${status}\`%0A%0ANicht im Running-Zustand!"
        return 1
    fi

    log "INFO" "n8n container is running"
    return 0
}

check_n8n_version() {
    log "INFO" "Checking n8n version..."

    local container="n8n-email-analyzer"
    local current_version=$(docker exec "$container" n8n --version 2>/dev/null || echo "unknown")
    local version_file="$STATE_DIR/n8n_version"

    if [ ! -f "$version_file" ]; then
        echo "$current_version" > "$version_file"
        log "INFO" "Initial n8n version recorded: $current_version"
        return 0
    fi

    local stored_version=$(cat "$version_file")

    if [ "$current_version" != "$stored_version" ]; then
        local major_current=$(echo "$current_version" | cut -d. -f1)
        local major_stored=$(echo "$stored_version" | cut -d. -f1)

        if [ "$major_current" -lt "$major_stored" ]; then
            log "ERROR" "n8n VERSION DOWNGRADE! $stored_version -> $current_version"
            send_alert "🔴 CRITICAL" "N8N Version Downgrade" \
                "Version wurde zurückgestuft!%0A%0AAlt: \`${stored_version}\`%0ANeu: \`${current_version}\`%0A%0A⚠️ Mögliche Kompromittierung!"
        else
            log "INFO" "n8n version updated: $stored_version -> $current_version"
        fi

        echo "$current_version" > "$version_file"
    fi

    return 0
}

check_n8n_binary_integrity() {
    log "INFO" "Checking n8n binary integrity..."

    local container="n8n-email-analyzer"
    local binary_hash=$(docker exec "$container" sha256sum /usr/local/bin/n8n 2>/dev/null | cut -d' ' -f1 || echo "unknown")
    local hash_file="$STATE_DIR/n8n_binary_hash"

    if [ ! -f "$hash_file" ]; then
        echo "$binary_hash" > "$hash_file"
        log "INFO" "Initial n8n binary hash recorded"
        return 0
    fi

    local stored_hash=$(cat "$hash_file")

    if [ "$binary_hash" != "$stored_hash" ] && [ "$binary_hash" != "unknown" ]; then
        log "ERROR" "n8n binary MODIFIED!"
        send_alert "🔴 CRITICAL" "N8N Binary Modified" \
            "Die n8n-Binary wurde verändert!%0A%0A⚠️ Mögliche Kompromittierung!"
    fi

    return 0
}

# ============================================================================
# ALLGEMEINE SERVER-CHECKS
# ============================================================================

check_disk_space() {
    log "INFO" "Checking disk space..."

    local usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    local disk_info=$(df -h / | awk 'NR==2 {print $2 " total, " $3 " used, " $4 " available"}')

    if [ "$usage" -ge "$DISK_CRITICAL" ]; then
        log "ERROR" "Disk space CRITICAL: ${usage}%"
        send_alert "🔴 CRITICAL" "Disk Space Critical" \
            "Festplatte zu voll: *${usage}%*%0A%0A${disk_info}%0A%0ASofortiges Cleanup erforderlich!"
        return 1
    elif [ "$usage" -ge "$DISK_WARNING" ]; then
        log "WARNING" "Disk space high: ${usage}%"
        send_alert "🟠 WARNING" "Disk Space Warning" \
            "Festplatte wird voll: *${usage}%*%0A%0A${disk_info}%0A%0ABitte bald aufräumen."
        return 1
    fi

    log "INFO" "Disk space OK: ${usage}%"
    return 0
}

check_memory_usage() {
    log "INFO" "Checking memory usage..."

    local mem_usage=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2) * 100}')
    local mem_info=$(free -h | awk '/Mem:/ {print $2 " total, " $3 " used, " $4 " available"}')

    if [ "$mem_usage" -ge "$RAM_WARNING" ]; then
        log "WARNING" "Memory usage high: ${mem_usage}%"
        send_alert "🟠 WARNING" "High Memory Usage" \
            "RAM-Auslastung hoch: *${mem_usage}%*%0A%0A${mem_info}"
        return 1
    fi

    log "INFO" "Memory usage OK: ${mem_usage}%"
    return 0
}

check_cpu_usage() {
    log "INFO" "Checking CPU usage..."

    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d'.' -f1)

    if [ "$cpu_usage" -ge "$CPU_WARNING" ]; then
        log "WARNING" "CPU usage high: ${cpu_usage}%"
        send_alert "🟠 WARNING" "High CPU Usage" \
            "CPU-Auslastung hoch: *${cpu_usage}%*%0A%0ABitte Prozesse prüfen."
        return 1
    fi

    log "INFO" "CPU usage OK: ${cpu_usage}%"
    return 0
}

check_ssh_attacks() {
    log "INFO" "Checking for SSH attacks..."

    local check_file="$STATE_DIR/last_ssh_check"
    local now=$(date +%s)

    # Prüfe seit letztem Check
    local since_minutes=60
    if [ -f "$check_file" ]; then
        local last_check=$(cat "$check_file")
        since_minutes=$(( (now - last_check) / 60 + 1 ))
    fi

    # Zähle fehlgeschlagene SSH-Logins seit letztem Check
    local failed_logins=$(grep "Failed password" /var/log/auth.log 2>/dev/null | \
        awk -v since="$since_minutes" '{
            cmd="date -d \"" $1 " " $2 " " $3 "\" +%s 2>/dev/null"
            cmd | getline timestamp
            close(cmd)
            if (timestamp >= systime() - since*60) print
        }' | wc -l)

    # Prüfe auch Root-Login-Versuche
    local root_attempts=$(grep "Failed password for root" /var/log/auth.log 2>/dev/null | tail -10 | wc -l)

    if [ "$failed_logins" -gt "$SSH_FAILED_THRESHOLD" ]; then
        log "WARNING" "Multiple failed SSH logins: $failed_logins in last ${since_minutes} minutes"
        send_alert "🟠 WARNING" "SSH Brute-Force Detected" \
            "Fehlgeschlagene SSH-Logins: *${failed_logins}*%0AZeitraum: ${since_minutes} Minuten%0A%0AMöglicher Angriff!"
    fi

    if [ "$root_attempts" -gt 3 ]; then
        log "WARNING" "Root login attempts detected: $root_attempts"
        send_alert "🟠 WARNING" "Root Login Attempts" \
            "Root-Login-Versuche: *${root_attempts}*%0A%0ASehr verdächtig!"
    fi

    echo "$now" > "$check_file"
    return 0
}

check_system_updates() {
    log "INFO" "Checking for system updates..."

    # Update package cache (silent)
    apt-get update > /dev/null 2>&1 || true

    local security_updates=$(apt-get -s upgrade 2>/dev/null | grep -i security | wc -l)
    local total_updates=$(apt list --upgradable 2>/dev/null | grep -c upgradable || echo 0)

    if [ "$security_updates" -gt 0 ]; then
        log "WARNING" "Security updates available: $security_updates"
        send_alert "🟠 WARNING" "Security Updates Available" \
            "Sicherheits-Updates verfügbar: *${security_updates}*%0AGesamte Updates: ${total_updates}%0A%0ABitte zeitnah installieren!"
        return 1
    elif [ "$total_updates" -gt 20 ]; then
        log "INFO" "Many updates available: $total_updates"
        send_alert "🟢 INFO" "System Updates Available" \
            "Updates verfügbar: *${total_updates}*%0A%0AKeine kritischen Sicherheits-Updates."
    fi

    log "INFO" "System updates: $total_updates total, $security_updates security"
    return 0
}

check_docker_containers() {
    log "INFO" "Checking Docker containers..."

    # Prüfe Docker-Daemon
    if ! systemctl is-active --quiet docker; then
        log "ERROR" "Docker daemon is NOT running!"
        send_alert "🔴 CRITICAL" "Docker Daemon Down" \
            "Docker-Service ist nicht aktiv!%0A%0AContainer sind offline!"
        return 1
    fi

    # Prüfe auf gestoppte Container (die laufen sollten)
    local stopped_expected=$(docker ps -a --format '{{.Names}}\t{{.Status}}' | \
        grep -E "^($EXPECTED_CONTAINERS)" | grep -v "Up" || echo "")

    if [ -n "$stopped_expected" ]; then
        log "WARNING" "Expected containers not running: $stopped_expected"
        send_alert "🟠 WARNING" "Container Stopped" \
            "Erwarteter Container läuft nicht:%0A%0A\`${stopped_expected}\`"
        return 1
    fi

    # Prüfe auf unerwartete Container
    local unexpected=$(docker ps --format '{{.Names}}' | \
        grep -Ev "^($EXPECTED_CONTAINERS)$" || echo "")

    if [ -n "$unexpected" ]; then
        log "INFO" "Unexpected containers running: $unexpected"
        send_alert "🟢 INFO" "Unbekannte Container" \
            "Folgende Container laufen:%0A%0A\`${unexpected}\`%0A%0ABitte prüfen wenn unerwartet."
    fi

    log "INFO" "Docker containers OK"
    return 0
}

check_firewall_status() {
    log "INFO" "Checking firewall status..."

    if ! command -v ufw &> /dev/null; then
        log "WARNING" "UFW not installed!"
        return 0
    fi

    local ufw_status=$(ufw status | head -1 | awk '{print $2}')

    if [ "$ufw_status" != "active" ]; then
        log "ERROR" "Firewall is NOT active!"
        send_alert "🔴 CRITICAL" "Firewall Disabled" \
            "UFW Firewall ist *nicht aktiv*!%0A%0AServer ist ungeschützt!"
        return 1
    fi

    log "INFO" "Firewall is active"
    return 0
}

check_suspicious_network() {
    log "INFO" "Checking for suspicious network connections..."

    # Prüfe auf n8n-Verbindungen von außen (sollte nur localhost sein)
    local n8n_external=$(netstat -tnp 2>/dev/null | grep ':5678' | grep -v '127.0.0.1' | wc -l)

    if [ "$n8n_external" -gt 0 ]; then
        local conns=$(netstat -tnp 2>/dev/null | grep ':5678' | grep -v '127.0.0.1' | head -5)
        log "WARNING" "External connections to n8n port detected!"
        send_alert "🟠 WARNING" "N8N Externe Verbindungen" \
            "Externe Verbindungen zu Port 5678!%0A%0A\`${conns}\`%0A%0ADies sollte nicht passieren!"
    fi

    # Prüfe auf viele ESTABLISHED Verbindungen (möglicher DDoS)
    local established_count=$(netstat -an | grep ESTABLISHED | wc -l)

    if [ "$established_count" -gt 500 ]; then
        log "WARNING" "High number of established connections: $established_count"
        send_alert "🟠 WARNING" "Hohe Anzahl Verbindungen" \
            "ESTABLISHED Connections: *${established_count}*%0A%0AMöglicher DDoS oder Traffic-Spike."
    fi

    return 0
}

check_failed_services() {
    log "INFO" "Checking for failed systemd services..."

    local failed_services=$(systemctl list-units --state=failed --no-pager --no-legend | wc -l)

    if [ "$failed_services" -gt 0 ]; then
        local services=$(systemctl list-units --state=failed --no-pager --no-legend | awk '{print $1}' | head -5 | tr '\n' ' ')
        log "WARNING" "Failed services detected: $services"
        send_alert "🟠 WARNING" "Failed Services" \
            "Fehlgeschlagene Services: *${failed_services}*%0A%0A\`${services}\`%0A%0ABitte prüfen!"
        return 1
    fi

    log "INFO" "No failed services"
    return 0
}

# ============================================================================
# HAUPTFUNKTION
# ============================================================================

main() {
    log "INFO" "========================================="
    log "INFO" "Server Security Monitor gestartet"
    log "INFO" "Server: $SERVER_NAME ($SERVER_IP)"
    log "INFO" "========================================="

    local exit_code=0

    # N8N-spezifische Checks
    log "INFO" "--- N8N CHECKS ---"
    check_n8n_container || exit_code=1
    check_n8n_version || exit_code=1
    check_n8n_binary_integrity || exit_code=1

    # Server-Checks
    log "INFO" "--- SERVER CHECKS ---"
    check_disk_space || exit_code=1
    check_memory_usage || exit_code=1
    check_cpu_usage || exit_code=1
    check_ssh_attacks || exit_code=1
    check_system_updates || exit_code=1
    check_docker_containers || exit_code=1
    check_firewall_status || exit_code=1
    check_suspicious_network || exit_code=1
    check_failed_services || exit_code=1

    if [ $exit_code -eq 0 ]; then
        log "INFO" "✅ All security checks passed"
    else
        log "WARNING" "⚠️  Some security checks failed (see above)"
    fi

    log "INFO" "========================================="
    log "INFO" "Server Security Monitor abgeschlossen"
    log "INFO" "========================================="

    return $exit_code
}

# Führe aus
main "$@"
