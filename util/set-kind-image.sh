#!/usr/bin/env bash
set -uo pipefail

kind_image="kindest/node:v1.33.4@sha256:25a6018e48dfcaee478f4a59af81157a437f15e6e140bf103f85a2e7cd0cbbf2"

set_kind_image () {
  local kind="$1"
  printf "Updating kind config file: %s\n" "$kind"
  yq -i ".nodes[].image=\"$kind_image\"" "$kind"
}

printf "Using kind image %s\n" "$kind_image"

find . -path ./.git -prune -o -type f -name '*.yaml' -print | while read -r filename
do
  if [[ "$(yq 'contains({"apiVersion": "kind.x-k8s.io/v1alpha4", "kind": "Cluster"})' "$filename" 2>/dev/null)" == "true" ]]; then
    set_kind_image "$filename"
  fi
done

