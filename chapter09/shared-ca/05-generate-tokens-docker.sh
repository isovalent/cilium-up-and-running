#!/usr/bin/env bash
set -euxo pipefail

root_token="$(docker logs openbao 2>&1 | grep "Root Token: " | cut -d' ' -f 3)"
bao () {
  docker exec \
    --env BAO_ADDR='http://0.0.0.0:8200' \
    --env BAO_TOKEN="$root_token" \
    openbao \
    bao "$@"
}

clusters=(red green blue)
for i in "${!clusters[@]}"; do
  name="${clusters[$i]}"
  bao \
    token create \
    --field token \
    | \
  kubectl \
    --context "kind-$name" \
    --namespace kube-system \
    --save-config \
    --dry-run=client \
    create secret generic \
    cert-manager-openbao-token \
    --from-file=token=/dev/stdin \
    --output yaml \
    | \
  kubectl apply \
    --context "kind-$name" \
    --namespace kube-system \
    --filename -
done