#!/usr/bin/env bash
set -euxo pipefail

kind create cluster \
  --config kind.yaml \
  --name tls

helm upgrade --install \
  cilium cilium/cilium \
  --kube-context kind-tls \
  --namespace kube-system \
  --version "1.18.1" \
  --values cilium.yaml

