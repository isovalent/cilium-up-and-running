#!/bin/bash

set -euo pipefail

TARGET_IP="${1:-}"
TARGET_PORT=8080
PORT_START=60000
NUM_PORTS=50
SLEEP_BETWEEN=1
OUTPUT_DIR="./maglev-results"

if [[ -z "$TARGET_IP" ]]; then
  echo "Usage: $0 <target-ip>"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

timestamp=$(date +%Y%m%d-%H%M%S)
outfile="$OUTPUT_DIR/result-$timestamp.txt"

echo "🌐 Testing Maglev consistency to $TARGET_IP:$TARGET_PORT"
echo "🔁 Using source ports $PORT_START to $((PORT_START + NUM_PORTS - 1))"
echo "📝 Saving results to $outfile"
echo

for ((i = 0; i < NUM_PORTS; i++)); do
  src_port=$((PORT_START + i))

  echo -n "Port $src_port: "

  result=$(curl -s --max-time 2 --local-port "$src_port" "$TARGET_IP:$TARGET_PORT" 2>/dev/null || echo "CURL_ERR")

  if [[ "$result" == "CURL_ERR" ]]; then
    echo "$src_port -> ERROR (connection failed)" | tee -a "$outfile"
  elif echo "$result" | head -1 | grep -q "Request served by"; then
    backend=$(echo "$result" | head -1 | grep "Request served by" | awk '{print $4}')
    echo "$src_port -> $backend" | tee -a "$outfile"
  elif echo "$result" | grep -q "Hostname:"; then
    # Fallback for other echo server images
    backend=$(echo "$result" | grep "Hostname:" | awk '{print $2}')
    echo "$src_port -> $backend" | tee -a "$outfile"
  else
    # Debug: show first line of response
    first_line=$(echo "$result" | head -1)
    echo "$src_port -> ERROR (first line: '$first_line')" | tee -a "$outfile"
  fi

  sleep "$SLEEP_BETWEEN"
done

# Analyze results
echo
echo "📊 Results Analysis:"

# Count successful vs error responses
success_count=$(grep -v "ERROR" "$outfile" | wc -l)
error_count=$(grep "ERROR" "$outfile" | wc -l)
total_count=$((success_count + error_count))

echo "   ✅ Successful responses: $success_count/$total_count"
echo "   ❌ Error responses: $error_count/$total_count"

if [ "$error_count" -gt 0 ]; then
  echo "   ⚠️  Errors detected - check connectivity and service health"
fi

# Find previous successful result file for comparison
previous=$(ls -t "$OUTPUT_DIR"/result-*.txt | grep -v "$outfile" | head -n1 || true)

if [[ -n "$previous" ]]; then
  echo
  echo "🔍 Comparing to previous result: $previous"
  
  # Only compare if both files have successful results
  prev_success=$(grep -v "ERROR" "$previous" | wc -l || echo "0")
  if [ "$success_count" -gt 0 ] && [ "$prev_success" -gt 0 ]; then
    if diff -q "$previous" "$outfile" > /dev/null; then
      echo "   ✅ IDENTICAL: Maglev consistent hashing is working correctly!"
    else
      echo "   ❌ DIFFERENT: Results changed - this indicates inconsistent load balancing"
      echo "   📋 Differences:"
      diff "$previous" "$outfile" || true
    fi
  else
    echo "   ⚠️  Cannot compare - one or both files contain errors"
  fi
else
  echo
  echo "ℹ️  No previous result file to compare."
  if [ "$success_count" -gt 0 ]; then
    echo "   💡 Run this test again to verify Maglev consistency"
  fi
fi