#!/usr/bin/env bash
set -euxo pipefail

podman run \
  --detach \
  --name openbao \
  --env VAULT_ADDR='http://0.0.0.0:8200' \
 'quay.io/openbao/openbao:2.4.1'
