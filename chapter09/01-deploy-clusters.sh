#!/usr/bin/env bash
set -euxo pipefail

clusters=(red green blue)
for i in "${!clusters[@]}"; do
  kind create cluster --config kind.yaml --name "${clusters[$i]}"
done

