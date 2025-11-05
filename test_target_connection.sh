#!/bin/bash
# Test if panel can reach target server

echo "Testing connectivity from panel to target server..."

# Test 1: Basic TCP connection
echo "1. Testing TCP connection to 65.109.197.226:8080 from panel:"
docker exec smite-panel sh -c "timeout 3 bash -c '</dev/tcp/65.109.197.226/8080' 2>&1 && echo 'Connection successful' || echo 'Connection failed'"

# Test 2: Check if we can telnet/connect
echo ""
echo "2. Testing with gost directly (should show connection details):"
docker exec smite-panel /usr/local/bin/gost -L=tcp://0.0.0.0:9999 -F=tcp://65.109.197.226:8080 &
GOST_PID=$!
sleep 2
echo "Gost PID: $GOST_PID"
docker exec smite-panel ps aux | grep $GOST_PID || echo "Gost not running"

# Test 3: Try to connect through the test gost
echo ""
echo "3. Testing connection through gost proxy:"
timeout 2 bash -c '</dev/tcp/65.109.197.223/9999' 2>&1 && echo "Connected through gost" || echo "Failed to connect through gost"

# Cleanup
docker exec smite-panel pkill -f "gost.*9999" 2>/dev/null
sleep 1

echo ""
echo "4. Check target server firewall/rules:"
echo "   On target server (65.109.197.226), check if it accepts connections from panel IP (65.109.197.223)"

