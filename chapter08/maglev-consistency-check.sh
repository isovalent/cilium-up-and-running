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

  result=$(curl -s --max-time 2 --local-port "$src_port" "$TARGET_IP:$TARGET_PORT" || echo "ERR")

  if echo "$result" | grep -q "Hostname:"; then
    backend=$(echo "$result" | grep "Hostname:" | awk '{print $2}')
    echo "$src_port -> $backend" | tee -a "$outfile"
  else
    echo "$src_port -> ERROR" | tee -a "$outfile"
  fi

  sleep "$SLEEP_BETWEEN"
done

# Find previous result file for comparison
previous=$(ls -t "$OUTPUT_DIR"/result-*.txt | grep -v "$outfile" | head -n1 || true)

if [[ -n "$previous" ]]; then
  echo
  echo "🔍 Comparing to previous result: $previous"
  echo
  diff -u "$previous" "$outfile" || true
else
  echo
  echo "ℹ️ No previous result file to compare."
fi