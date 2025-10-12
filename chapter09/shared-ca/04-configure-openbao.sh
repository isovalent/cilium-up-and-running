#!/usr/bin/env bash
set -euxo pipefail

root_token="$(podman logs openbao 2>&1 | grep "Root Token: " | cut -d' ' -f 3)"
bao () {
  podman exec \
    --env BAO_ADDR='http://0.0.0.0:8200' \
    --env BAO_TOKEN="$root_token" \
    openbao \
    bao "$@"
}

bao secrets enable pki
bao secrets tune \
  --max-lease-ttl=87600h \
  pki
bao write pki/root/generate/internal \
  common_name="Root CA" \
  ttl=87600h
bao write pki/roles/up-and-running \
  allow_any_name=true

