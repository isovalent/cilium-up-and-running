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
  tcpdump -vXXli "$bridge_name" -s0 udp and port 51871

