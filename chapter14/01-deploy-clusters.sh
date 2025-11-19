#!/usr/bin/env bash
set -euxo pipefail

cluster_name="ch13"
kind create cluster \
  --config kind.yaml \
  --name "$cluster_name"
context="kind-$cluster_name"


control_plane_ip="$(kubectl get nodes --context "$context" --selector 'node-role.kubernetes.io/control-plane' --output yaml | yq '.items[0].status.addresses[] | select(.type=="InternalIP") | .address')"

helm upgrade --install \
  cilium cilium/cilium \
  --kube-context "$context" \
  --namespace kube-system \
  --version "1.18.1" \
  --values cilium.yaml \
  --set "k8sServiceHost=$control_plane_ip"

