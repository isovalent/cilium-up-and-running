#!/usr/bin/env bash
set -euxo pipefail

kind create cluster \
  --config kind.yaml \
  --name chapter13

helm upgrade --install \
  cilium cilium/cilium \
  --kube-context kind-chapter13 \
  --namespace kube-system \
  --version "1.18.1" \
  --set "hubble.relay.enabled=true"

