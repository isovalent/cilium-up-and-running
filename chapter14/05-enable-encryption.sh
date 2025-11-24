#!/usr/bin/env bash
set -euxo pipefail

cluster_name="ch14"
context="kind-$cluster_name"

helm upgrade --install \
  cilium cilium/cilium \
  --kube-context "$context" \
  --namespace kube-system \
  --version "1.18.4" \
  --reuse-values \
  --set "encryption.enabled=true"

kubectl rollout restart \
  --context "$context" \
  --namespace kube-system \
  deployment/cilium-operator \
  daemonset/cilium

