#!/bin/bash
# Automatisches Setup für n8n-Zugriff über SSH-Tunnel
# Verwendung: source /root/.claude/scripts/setup-n8n-tunnel.sh

set -e

# Farben für Output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 N8N SSH-Tunnel Setup${NC}"
echo "================================"

# 1. Prüfen ob Tunnel bereits läuft
if ps aux | grep -q "[s]sh.*5678.*bernd@46.224.220.236"; then
    echo -e "${GREEN}✅ SSH-Tunnel läuft bereits${NC}"
    TUNNEL_PID=$(ps aux | grep "[s]sh.*5678.*bernd@46.224.220.236" | awk '{print $2}')
    echo -e "   PID: $TUNNEL_PID"
else
    echo -e "${YELLOW}⏳ Starte SSH-Tunnel...${NC}"

    # SSH-Tunnel starten
    ssh -f -N -L 5678:localhost:5678 \
        -p 2222 \
        bernd@46.224.220.236 \
        -i ~/.ssh/bernd_ed25519 \
        -o StrictHostKeyChecking=no \
        -o ServerAliveInterval=60 \
        -o ServerAliveCountMax=3

    # Kurz warten
    sleep 2

    # Prüfen ob erfolgreich
    if ps aux | grep -q "[s]sh.*5678"; then
        TUNNEL_PID=$(ps aux | grep "[s]sh.*5678.*bernd@46.224.220.236" | awk '{print $2}')
        echo -e "${GREEN}✅ SSH-Tunnel gestartet (PID: $TUNNEL_PID)${NC}"
    else
        echo -e "${RED}❌ Fehler beim Starten des Tunnels${NC}"
        exit 1
    fi
fi

# 2. Verbindung testen
echo -e "${YELLOW}⏳ Teste n8n-Verbindung...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5678 --max-time 5)

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ n8n erreichbar (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}❌ n8n nicht erreichbar (HTTP $HTTP_CODE)${NC}"
    echo -e "${YELLOW}   Prüfe ob n8n auf dem Server läuft${NC}"
    exit 1
fi

# 3. API-Key laden
if [ -f ~/.claude/secrets/n8n-api-key ]; then
    export N8N_API_KEY=$(cat ~/.claude/secrets/n8n-api-key)
    echo -e "${GREEN}✅ API-Key geladen${NC}"
else
    echo -e "${RED}❌ API-Key nicht gefunden: ~/.claude/secrets/n8n-api-key${NC}"
    exit 1
fi

# 4. API-Zugriff testen
echo -e "${YELLOW}⏳ Teste n8n API...${NC}"
API_TEST=$(curl -s "http://localhost:5678/api/v1/workflows" \
    -H "X-N8N-API-KEY: $N8N_API_KEY" \
    --max-time 5)

if echo "$API_TEST" | grep -q '"data"'; then
    WORKFLOW_COUNT=$(echo "$API_TEST" | python3 -c "import sys, json; print(len(json.load(sys.stdin)['data']))" 2>/dev/null || echo "?")
    echo -e "${GREEN}✅ n8n API funktioniert ($WORKFLOW_COUNT Workflows)${NC}"
else
    echo -e "${RED}❌ n8n API nicht erreichbar${NC}"
    exit 1
fi

# 5. Helper-Funktionen exportieren
echo -e "${YELLOW}⏳ Lade Helper-Funktionen...${NC}"

# Funktion: Workflows auflisten
n8n_list_workflows() {
    curl -s "http://localhost:5678/api/v1/workflows" \
        -H "X-N8N-API-KEY: $N8N_API_KEY" \
        | python3 -m json.tool
}

# Funktion: Workflow abrufen
n8n_get_workflow() {
    local workflow_id=$1
    if [ -z "$workflow_id" ]; then
        echo "Usage: n8n_get_workflow <workflow_id>"
        return 1
    fi
    curl -s "http://localhost:5678/api/v1/workflows/$workflow_id" \
        -H "X-N8N-API-KEY: $N8N_API_KEY" \
        | python3 -m json.tool
}

# Funktion: Workflow speichern
n8n_save_workflow() {
    local workflow_id=$1
    local output_file=${2:-"workflow-$workflow_id.json"}
    if [ -z "$workflow_id" ]; then
        echo "Usage: n8n_save_workflow <workflow_id> [output_file]"
        return 1
    fi
    curl -s "http://localhost:5678/api/v1/workflows/$workflow_id" \
        -H "X-N8N-API-KEY: $N8N_API_KEY" \
        -o "$output_file"
    echo "Workflow saved to: $output_file"
}

# Funktion: Tunnel stoppen
stop_n8n_tunnel() {
    local pid=$(ps aux | grep "[s]sh.*5678.*bernd@46.224.220.236" | awk '{print $2}')
    if [ -n "$pid" ]; then
        kill $pid
        echo -e "${GREEN}✅ SSH-Tunnel gestoppt (PID: $pid)${NC}"
    else
        echo -e "${YELLOW}⚠️  Kein SSH-Tunnel gefunden${NC}"
    fi
}

export -f n8n_list_workflows
export -f n8n_get_workflow
export -f n8n_save_workflow
export -f stop_n8n_tunnel

echo -e "${GREEN}✅ Helper-Funktionen geladen${NC}"
echo ""
echo -e "${GREEN}════════════════════════════════════${NC}"
echo -e "${GREEN}✅ n8n-Zugriff ist bereit!${NC}"
echo -e "${GREEN}════════════════════════════════════${NC}"
echo ""
echo "Verfügbare Funktionen:"
echo "  • n8n_list_workflows           - Alle Workflows auflisten"
echo "  • n8n_get_workflow <id>        - Workflow anzeigen"
echo "  • n8n_save_workflow <id> [file] - Workflow speichern"
echo "  • stop_n8n_tunnel              - Tunnel beenden"
echo ""
echo "Umgebungsvariablen:"
echo "  • N8N_API_KEY                  - API-Key für n8n"
echo ""
echo "Beispiele:"
echo "  n8n_list_workflows"
echo "  n8n_save_workflow 3U4oaAs0M5WpZY6m /mnt/c/Users/Ruben/my-workflow.json"
