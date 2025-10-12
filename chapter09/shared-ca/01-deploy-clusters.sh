#!/usr/bin/env bash
set -euxo pipefail

clusters=(red green blue)
for i in "${!clusters[@]}"; do
  name="${clusters[$i]}"
  kind create cluster \
    --config kind.yaml \
    --name "$name"
done

