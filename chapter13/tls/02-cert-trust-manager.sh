#!/usr/bin/env bash
set -euxo pipefail

helm upgrade --install \
    cert-manager oci://quay.io/jetstack/charts/cert-manager \
    --kube-context kind-tls \
    --version v1.19.0 \
    --namespace cert-manager \
    --create-namespace \
    --set crds.enabled=true

helm upgrade --install \
    trust-manager oci://quay.io/jetstack/charts/trust-manager \
    --kube-context kind-tls \
    --version v0.20.2 \
    --namespace cert-manager \
    --set secretTargets.enabled=true \
    --set "secretTargets.authorizedSecrets[0]=public-ca-bundle"
