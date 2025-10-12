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
    --version "1.18.1" \
    --values cilium-no-mesh.yaml \
    --set "cluster.id=$id" \
    --set "cluster.name=$name" \
    --set "ipam.operator.clusterPoolIPv4PodCIDRList=10.$id.0.0/16"
  helm upgrade --install \
    --kube-context "kind-$name" \
    cert-manager oci://quay.io/jetstack/charts/cert-manager \
    --version v1.19.0 \
    --namespace cert-manager \
    --create-namespace \
    --set crds.enabled=true
done

