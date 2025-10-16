#!/usr/bin/env bash
set -euxo pipefail

kind create cluster \
  --config kind.yaml \
  --name chapter12

helm upgrade --install \
  cilium cilium/cilium \
  --kube-context kind-chapter12 \
  --namespace kube-system \
  --version "1.18.1" \
  --set "hubble.relay.enabled=true"

