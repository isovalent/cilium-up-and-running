#!/usr/bin/env bash
set -euxo pipefail

kubectl label \
  --context kind-tls \
  namespace cilium-secrets \
  secrets-namespace="true"

kubectl apply \
  --context kind-tls \
  --filename public-ca-bundle.yaml

