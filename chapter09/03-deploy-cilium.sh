#!/usr/bin/env bash
set -euxo pipefail

clusters=(red green blue)
for i in "${!clusters[@]}"; do
  name="${clusters[$i]}"
  id="$((i + 1))"
  helm upgrade --install \
    --kube-context "kind-$name" \
    cilium cilium/cilium \
    --namespace kube-system \
    --version "1.18.5" \
    --values cilium.yaml \
    --set "cluster.id=$id" \
    --set "cluster.name=$name" \
    --set "ipam.operator.clusterPoolIPv4PodCIDRList=10.$id.0.0/16"
  kubectl rollout restart \
    --context "kind-$name" \
    --namespace kube-system \
    deployment/clustermesh-apiserver \
    deployment/cilium-operator \
    daemonset/cilium-envoy \
    daemonset/cilium
done

