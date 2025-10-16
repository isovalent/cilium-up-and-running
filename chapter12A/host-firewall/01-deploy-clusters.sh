#!/usr/bin/env bash
set -euxo pipefail

kind create cluster \
  --config kind.yaml \
  --name host-firewall

control_plane_ip="$(kubectl get node host-firewall-control-plane -o yaml | yq '.status.addresses[] | select(.type=="InternalIP") | .address')"

helm upgrade --install \
  cilium cilium/cilium \
  --kube-context kind-host-firewall \
  --namespace kube-system \
  --version "1.18.1" \
  --values cilium.yaml \
  --set "k8sServiceHost=$control_plane_ip"

