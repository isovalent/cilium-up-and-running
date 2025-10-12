#!/usr/bin/env bash
set -euxo pipefail

bao_address="http://$(podman inspect --format '{{ .NetworkSettings.IPAddress }}' openbao):8200"

cp issuer.template.yaml issuer.yaml
yq -i ".spec.vault.server=\"$bao_address\"" issuer.yaml

clusters=(red green blue)
for i in "${!clusters[@]}"; do
  name="${clusters[$i]}"
  kubectl \
    --context "kind-$name" \
    apply \
    --filename issuer.yaml
done

