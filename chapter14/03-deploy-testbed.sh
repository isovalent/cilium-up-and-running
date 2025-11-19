#!/usr/bin/env bash
set -euxo pipefail

cluster_name="ch13"
context="kind-$cluster_name"

kubectl apply \
  --context "$context" \
  --filename testbed.yaml

