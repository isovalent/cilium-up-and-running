#!/usr/bin/env bash
set -euxo pipefail

bridge_name="$(docker network inspect kind \
  | jq -r '.[0] |
    .Options["com.docker.network.bridge.name"] //
    ("br-" + .Id[:12])')"

docker run \
  --network host \
  --privileged \
  -it \
  nicolaka/netshoot \
  tcpdump -lAi "$bridge_name" \
  | grep "Bearer"

