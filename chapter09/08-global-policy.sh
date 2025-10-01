#!/usr/bin/env bash
set -euxo pipefail

# Remove deployment from red cluster
kubectl delete \
  --context kind-red \
  --ignore-not-found \
  deployment nginx

service_clusters=(green blue)
for i in "${!service_clusters[@]}"; do
  name="${service_clusters[$i]}"
  kubectl apply \
    --context "kind-$name" \
    --filename nginx-policy.yaml
done

kubectl apply \
  --context "kind-red" \
  --filename frontend-policy.yaml

