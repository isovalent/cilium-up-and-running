#!/usr/bin/env bash

# Extract the root token from OpenBao logs (development mode)
BAO_DEV_ROOT_TOKEN_ID=$(docker logs openbao 2>&1 | grep "Root Token:" | awk '{print $3}')

function bao() {
  docker exec -e BAO_TOKEN=$BAO_DEV_ROOT_TOKEN_ID -e BAO_ADDR=http://0.0.0.0:8200 openbao bao "$@"
}

export BAO_TOKEN=$BAO_DEV_ROOT_TOKEN_ID
export BAO_ADDR=http://127.0.0.1:8200

# Enable PKI secrets engine
bao secrets enable pki

# Tune secrets engine
bao secrets tune -max-lease-ttl=87600h pki

# Generate the root certificate
bao write pki/root/generate/internal \
  common_name="Cilium in action tutorial" \
  ttl=87600h

# Configure PKI role
bao write pki/roles/up-and-running \
  allow_any_name=true