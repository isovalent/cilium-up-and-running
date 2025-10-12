#!/usr/bin/env bash
set -euxo pipefail

get_node_ips () {
  local name="$1"
  kubectl \
    --context "kind-$name" \
    get nodes \
    -o jsonpath='{range .items[*]}{"\""}{.status.addresses[?(@.type=="InternalIP")].address}{"\"\n"}{end}'
}

output_file="cilium.yaml"
cp cilium.template.yaml "$output_file"

clusters=(red green blue)
for i in "${!clusters[@]}"; do
  cluster_name="${clusters[$i]}"
  mapfile -t node_ips < <(get_node_ips "$cluster_name")
  for j in "${!node_ips[@]}"; do
    echo "${node_ips[$j]}"
  done
  yq -i ".clustermesh.config.clusters[$i]={\"name\": \"${clusters[$i]}\", \"port\": 32379, \"id\": "$((i + 1))", \"ips\": [$(IFS=,; echo "${node_ips[*]}")]}" "$output_file"
done

