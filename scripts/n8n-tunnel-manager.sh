#!/bin/bash
# N8N SSH Tunnel Manager
# Erstellt und überwacht SSH-Tunnel zu n8n auf Hetzner-Server

TUNNEL_PID_FILE="/tmp/n8n-tunnel.pid"
LOG_FILE="/tmp/n8n-tunnel.log"

# Funktion: Prüfe ob Tunnel läuft
is_tunnel_running() {
    if [ -f "$TUNNEL_PID_FILE" ]; then
        PID=$(cat "$TUNNEL_PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            return 0  # Tunnel läuft
        fi
    fi
    return 1  # Tunnel läuft nicht
}

# Funktion: Starte Tunnel
start_tunnel() {
    echo "[$(date)] Starting n8n SSH tunnel..." | tee -a "$LOG_FILE"

    # Entferne alten PID-File
    rm -f "$TUNNEL_PID_FILE"

    # Starte SSH-Tunnel im Hintergrund
    ssh -f -N -L 5678:localhost:5678 -o ServerAliveInterval=60 -o ServerAliveCountMax=3 hetzner

    # Speichere PID
    sleep 1
    PID=$(ps aux | grep "ssh.*5678:localhost:5678" | grep -v grep | awk '{print $2}' | head -1)

    if [ -n "$PID" ]; then
        echo "$PID" > "$TUNNEL_PID_FILE"
        echo "[$(date)] Tunnel started with PID: $PID" | tee -a "$LOG_FILE"
        return 0
    else
        echo "[$(date)] ERROR: Failed to start tunnel" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Funktion: Stoppe Tunnel
stop_tunnel() {
    echo "[$(date)] Stopping n8n SSH tunnel..." | tee -a "$LOG_FILE"

    if is_tunnel_running; then
        PID=$(cat "$TUNNEL_PID_FILE")
        kill "$PID" 2>/dev/null
        rm -f "$TUNNEL_PID_FILE"
        echo "[$(date)] Tunnel stopped (PID: $PID)" | tee -a "$LOG_FILE"
    else
        echo "[$(date)] No tunnel running" | tee -a "$LOG_FILE"
    fi
}

# Funktion: Status prüfen
status_tunnel() {
    if is_tunnel_running; then
        PID=$(cat "$TUNNEL_PID_FILE")
        echo "✅ N8N Tunnel is RUNNING (PID: $PID)"

        # Teste Verbindung
        if curl -s -f http://localhost:5678/healthz > /dev/null 2>&1; then
            echo "✅ N8N is REACHABLE via tunnel"
        else
            echo "⚠️  Tunnel läuft, aber n8n nicht erreichbar"
        fi
    else
        echo "❌ N8N Tunnel is NOT running"
    fi
}

# Funktion: Restart
restart_tunnel() {
    stop_tunnel
    sleep 2
    start_tunnel
}

# Main
case "${1:-start}" in
    start)
        if is_tunnel_running; then
            echo "✅ Tunnel already running"
            status_tunnel
        else
            start_tunnel
        fi
        ;;
    stop)
        stop_tunnel
        ;;
    restart)
        restart_tunnel
        ;;
    status)
        status_tunnel
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
