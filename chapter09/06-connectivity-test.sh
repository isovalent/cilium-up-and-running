#!/usr/bin/env bash
set -euo pipefail

clusters=(red green blue)
for i in "${!clusters[@]}"; do
  for j in "${!clusters[@]}"; do
    if [ "$j" -gt "$i" ]; then
      cluster_a="${clusters[$i]}"
      cluster_b="${clusters[$j]}"
      echo "Testing $cluster_a and $cluster_b"
      cilium connectivity test --context "kind-$cluster_a" --multi-cluster "kind-$cluster_b" --test '!check-log-errors/no-errors-in-logs'
    fi
  done
done

