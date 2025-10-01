#!/usr/bin/env bash
set -euxo pipefail

clusters=(red green blue)
ca_bundle="ca-bundle.crt"
rm -f "$ca_bundle"
for i in "${!clusters[@]}"; do
  name="${clusters[$i]}"
  kubectl \
  --context "kind-$name" \
  --namespace kube-system \
  get secret \
  cilium-ca \
  -o jsonpath="{.data['ca\.crt']}" | base64 --decode >> "$ca_bundle"
done

yq -i ".tls.caBundle.content=\"$(cat ca-bundle.crt)\", .tls.caBundle.enabled=true" cilium.yaml

