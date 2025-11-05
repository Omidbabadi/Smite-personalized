#!/bin/bash
# Debug script for tunnel issues

echo "=== Debugging Tunnel Issues ==="
echo ""

echo "1. Checking running gost processes:"
docker exec smite-panel ps aux | grep gost | grep -v grep || echo "No gost processes found"
echo ""

echo "2. Checking what ports are listening:"
docker exec smite-panel netstat -tlnp 2>/dev/null | grep -E ":(8080|8090)" || echo "Ports 8080/8090 not found in netstat"
echo ""

echo "3. Checking gost log files:"
docker exec smite-panel ls -la /app/data/gost/*.log 2>/dev/null | head -5 || echo "No gost log files found"
echo ""

echo "4. Latest gost log (if exists):"
TUNNEL_ID=$(docker exec smite-panel curl -s http://localhost:8000/api/tunnels 2>/dev/null | python3 -c "import sys, json; data=json.load(sys.stdin); print(data[0]['id'] if data else '')" 2>/dev/null)
if [ ! -z "$TUNNEL_ID" ]; then
    echo "Tunnel ID: $TUNNEL_ID"
    docker exec smite-panel cat /app/data/gost/gost_${TUNNEL_ID}.log 2>/dev/null | tail -20 || echo "Log file not found"
else
    echo "Could not get tunnel ID"
fi
echo ""

echo "5. Current tunnel configuration:"
docker exec smite-panel curl -s http://localhost:8000/api/tunnels 2>/dev/null | python3 -m json.tool 2>/dev/null | head -30 || echo "Could not fetch tunnel config"
echo ""

echo "6. Testing if gost binary exists:"
docker exec smite-panel ls -la /usr/local/bin/gost 2>/dev/null || echo "gost binary not found"
echo ""

echo "7. Testing manual gost command (will fail if port in use):"
echo "Run this manually: docker exec smite-panel /usr/local/bin/gost -L=tcp://0.0.0.0:8080 -F=tcp://65.109.197.226:8080"

