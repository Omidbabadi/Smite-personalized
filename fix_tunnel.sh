#!/bin/bash
# Quick fix script for tunnel issues

echo "=== Fixing Tunnel Issues ==="
echo ""

echo "1. Stopping all gost processes..."
docker exec smite-panel pkill -9 gost 2>/dev/null || echo "No gost processes to kill"
sleep 1

echo ""
echo "2. Checking for listening ports..."
docker exec smite-panel netstat -tlnp 2>/dev/null | grep -E ":(8080|8090)" || echo "Ports 8080/8090 are free"

echo ""
echo "3. Getting tunnel ID..."
TUNNEL_ID=$(docker exec smite-panel curl -s http://localhost:8000/api/tunnels 2>/dev/null | python3 -c "import sys, json; data=json.load(sys.stdin); print(data[0]['id'] if data else 'NO_TUNNELS')" 2>/dev/null)
echo "Tunnel ID: $TUNNEL_ID"

if [ "$TUNNEL_ID" != "NO_TUNNELS" ] && [ ! -z "$TUNNEL_ID" ]; then
    echo ""
    echo "4. Tunnel configuration:"
    docker exec smite-panel curl -s http://localhost:8000/api/tunnels/$TUNNEL_ID 2>/dev/null | python3 -m json.tool 2>/dev/null | grep -A 10 "spec"
    
    echo ""
    echo "5. To fix:"
    echo "   - Delete this tunnel in the UI"
    echo "   - Rebuild: docker compose up -d --build smite-panel"
    echo "   - Create a NEW tunnel with:"
    echo "     * Listen Port: 8080"
    echo "     * Remote IP: 65.109.197.226"
    echo "     * Remote Port: 8080"
else
    echo ""
    echo "No tunnels found. Create a new tunnel in the UI."
fi

echo ""
echo "6. After creating tunnel, check logs:"
echo "   docker exec smite-panel tail -f /app/data/gost/gost_*.log"

