#!/usr/bin/env bash
set -euxo pipefail

bridge_name="$(docker network list \
  --format json \
  | jq -r '.[] | select(.name == "kind") | .network_interface')"

docker run \
  --network host \
  --privileged \
  -it \
  nicolaka/netshoot \
  tcpdump -lAi "$bridge_name" \
  | grep "Bearer"

