#!/usr/bin/env bash
set -euxo pipefail

cluster_name="ch14"
kind delete cluster \
  --name "$cluster_name"
