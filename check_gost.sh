#!/bin/bash
echo "=== Checking why gost isn't starting ==="
echo ""

echo "1. Panel logs (last 50 lines):"
docker logs smite-panel --tail 50 2>&1 | grep -E "(gost|forward|tunnel|restore)" || echo "No gost-related logs found"
echo ""

echo "2. Check if gost binary exists:"
docker exec smite-panel ls -la /usr/local/bin/gost 2>&1
echo ""

echo "3. Test gost manually:"
TUNNEL_ID="9671825d-797b-4be9-9035-15aa33d6514a"
echo "Running: /usr/local/bin/gost -L=tcp://0.0.0.0:8080 -F=tcp://65.109.197.226:8080"
docker exec smite-panel /usr/local/bin/gost -L=tcp://0.0.0.0:8080 -F=tcp://65.109.197.226:8080 &
sleep 2
echo ""

echo "4. Check if gost is now running:"
docker exec smite-panel ps aux | grep gost | grep -v grep || echo "Gost not running"
echo ""

echo "5. Check if port 8080 is listening:"
docker exec smite-panel netstat -tlnp 2>/dev/null | grep 8080 || echo "Port 8080 not listening"
echo ""

echo "6. Kill test gost:"
docker exec smite-panel pkill -f "gost.*8080" 2>/dev/null || echo "No gost to kill"

