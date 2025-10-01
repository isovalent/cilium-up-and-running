#!/usr/bin/env bash
set -euxo pipefail

clusters=(red green blue)
for i in "${!clusters[@]}"; do
  name="${clusters[$i]}"
  kubectl patch \
    --context "kind-$name" \
    --namespace kube-system \
    secret clustermesh-apiserver-remote-cert \
    --patch "{\"data\":{\"ca.crt\":\"$(cat ca-bundle.crt | base64)\"}}"
  kubectl rollout restart \
  --context "kind-$name" \
  --namespace kube-system \
  deployment/clustermesh-apiserver
done

