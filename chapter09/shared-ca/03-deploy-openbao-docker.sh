#!/usr/bin/env bash
set -euxo pipefail

docker run \
  --detach \
  --name openbao \
  --publish 8200:8200 \
  --env VAULT_ADDR='http://0.0.0.0:8200' \
  'quay.io/openbao/openbao:2.4.1'