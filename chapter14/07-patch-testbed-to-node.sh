#!/usr/bin/env bash
set -euxo pipefail

cluster_name=ch13
context="kind-$cluster_name"

kubectl patch \
  --context "$context" \
  deploy client \
  --type json \
  --patch-file /dev/stdin <<EOF
[
  {
    "op": "replace",
    "path": "/spec/template/spec/hostNetwork",
    "value": true
  },
  {
    "op": "replace",
    "path": "/spec/template/spec/dnsPolicy",
    "value": "ClusterFirstWithHostNet"
  }
]
EOF

