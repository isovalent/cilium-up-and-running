#!/usr/bin/env bash

# Simple Maglev consistency test from FRR container
# Tests that the same source port consistently hits the same backend

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info() {
    echo -e "${YELLOW}$1${NC}"
}

echo_success() {
    echo -e "${GREEN}$1${NC}"
}

TARGET_IP="${1:-192.168.100.0}"
NUM_TESTS="${2:-10}"

echo_info "🌐 Simple Maglev consistency test from FRR container"
echo_info "📍 Target: ${TARGET_IP}:8080"
echo_info "🔁 Testing $NUM_TESTS requests with fixed source ports"

# Check if FRR container is running
if ! docker ps --format "{{.Names}}" | grep -q "^frr$"; then
    echo "❌ FRR container not found. Please run ./setup-maglev.sh first."
    exit 1
fi

# Install curl in FRR container if not already installed
docker exec frr apk add curl 2>/dev/null || true

echo ""
echo_success "📊 Testing Maglev consistency:"
echo "Format: SourcePort -> Backend"
echo ""

# Test with fixed source ports
for i in $(seq 1 "$NUM_TESTS"); do
    src_port=$((60000 + i))
    
    # Get response and extract backend
    result=$(docker exec frr curl -s --max-time 2 --local-port "$src_port" "$TARGET_IP:8080" 2>/dev/null || echo "ERROR")
    
    if echo "$result" | grep -q "Request served by"; then
        backend=$(echo "$result" | head -1 | grep "Request served by" | awk '{print $4}')
        echo "Port $src_port -> $backend"
    else
        echo "Port $src_port -> ERROR"
    fi
    
    sleep 0.5
done

echo ""
echo_success "✅ Test complete!"
echo_info "💡 To verify Maglev consistency:"
echo "   1. Run this test again: ./simple-maglev-test.sh"
echo "   2. Compare the outputs - same source ports should hit same backends"
echo "   3. Different source ports may hit different backends (load balancing)"

echo ""
echo_info "⏳ Waiting a moment for port cleanup..."
sleep 3

