#!/usr/bin/env bash
set -euxo pipefail

clusters=(red green blue)
for i in "${!clusters[@]}"; do
  name="${clusters[$i]}"
  kubectl apply \
    --context "kind-$name" \
    --filename global-service.yaml
done

