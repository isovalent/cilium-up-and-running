#!/usr/bin/env bash

# Simple debug version to test one request
TARGET_IP="192.168.100.0"
TARGET_PORT=8080
TEST_PORT=60000

echo "🔍 Debug: Testing single request from FRR container"
echo "Target: $TARGET_IP:$TARGET_PORT"
echo "Source port: $TEST_PORT"
echo ""

echo "Raw curl response:"
result=$(docker exec frr curl -s --max-time 3 --local-port "$TEST_PORT" "$TARGET_IP:$TARGET_PORT" 2>&1)
echo "[$result]"
echo ""

echo "Checking for 'Request served by':"
if echo "$result" | grep -q "Request served by"; then
    backend=$(echo "$result" | grep "Request served by" | awk '{print $4}')
    echo "✅ Found backend: [$backend]"
else
    echo "❌ Not found"
fi

echo ""
echo "Checking for 'Hostname:':"
if echo "$result" | grep -q "Hostname:"; then
    backend=$(echo "$result" | grep "Hostname:" | awk '{print $2}')
    echo "✅ Found hostname: [$backend]"
else
    echo "❌ Not found"
fi
