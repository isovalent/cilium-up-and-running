#!/bin/bash

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo_success() {
    echo -e "${GREEN}$1${NC}"
}

echo_error() {
    echo -e "${RED}$1${NC}"
    exit 1
}

# Main setup
echo "Starting Cilium setup..."

# Clone Cilium repository
if [ ! -d "cilium" ]; then
    git clone https://github.com/cilium/cilium || echo_error "Failed to clone Cilium repository"
fi

cd cilium

sysctl fs.inotify.max_user_instances=1024

# Setup kind cluster with XDP
bash contrib/scripts/kind.sh --xdp || echo_error "Failed to create kind cluster"

# Wait for kind cluster to be ready
echo "Waiting for kind cluster to be ready..."
#kubectl wait --for=condition=Ready nodes --all --timeout=300s

mkdir -p ../manifests ../frr

# -----------------------------
# Add Cilium Helm Repo
# -----------------------------
helm repo add cilium https://helm.cilium.io/ || echo_error "Failed to add Cilium helm repo"
helm repo update

# -----------------------------
# Cilium Helm Values
# -----------------------------
cat << 'EOF' > ../manifests/values.yaml
kubeProxyReplacement: true
routingMode: native
ipv4NativeRoutingCIDR: "172.18.0.0/24"
autoDirectNodeRoutes: true
loadBalancer:
  acceleration: "native"
  mode: "dsr"
  algorithm: "maglev"
bgpControlPlane:
  enabled: true
EOF

helm install cilium cilium/cilium --version 1.17.5 -f ../manifests/values.yaml -n kube-system || echo_error "Failed to install Cilium"

echo "Waiting for Cilium to be ready..."
cilium status --wait

# -----------------------------
# LoadBalancer IP Pool
# -----------------------------
cat << 'EOF' > ../manifests/lb-ippool.yaml
apiVersion: "cilium.io/v2alpha1"
kind: CiliumLoadBalancerIPPool
metadata:
  name: "dsr-demo-pool"
spec:
  blocks:
  - cidr: "192.168.100.0/24"
EOF

kubectl apply -f ../manifests/lb-ippool.yaml || echo_error "Failed to apply LB IPAM CRD"

# -----------------------------
# BGP Configs
# -----------------------------
cat << 'EOF' > ../manifests/bgp-peer.yaml
apiVersion: cilium.io/v2alpha1
kind: CiliumBGPPeerConfig
metadata:
  name: frr
spec:
  families:
    - afi: ipv4
      safi: unicast
      advertisements:
        matchLabels:
          advertise: "bgp"
EOF

kubectl apply -f ../manifests/bgp-peer.yaml || echo_error "Failed to apply BGP peer config"

cat << 'EOF' > ../manifests/bgp-cluster.yaml
apiVersion: cilium.io/v2alpha1
kind: CiliumBGPClusterConfig
metadata:
  name: frr
spec:
  nodeSelector:
    matchLabels:
      cilium-bpg-peering: "true"
  bgpInstances:
  - name: "64513"
    localASN: 64513
    peers:
    - name: "frr"
      peerASN: 64512
      peerAddress: 172.18.0.4
      peerConfigRef:
        name: "frr"
EOF

kubectl apply -f ../manifests/bgp-cluster.yaml || echo_error "Failed to apply BGP cluster config"

cat << 'EOF' > ../manifests/bgp-advertisement.yaml
apiVersion: cilium.io/v2alpha1
kind: CiliumBGPAdvertisement
metadata:
  name: frr
  labels:
    advertise: "bgp"
spec:
  advertisements:
    - advertisementType: "Service"
      service:
        addresses:
          - LoadBalancerIP
      selector:
        matchExpressions:
          - {key: somekey, operator: NotIn, values: ['never-used-value']}
EOF

kubectl apply -f ../manifests/bgp-advertisement.yaml || echo_error "Failed to apply BGP advertisement config"

kubectl label node kind-worker cilium-bpg-peering="true" || echo_error "Failed to label kind-worker"
kubectl label node kind-control-plane cilium-bpg-peering="true" || echo_error "Failed to label control-plane"

# -----------------------------
# FRR Container Setup
# -----------------------------
cat << 'EOF' > ../frr/daemons
zebra=yes
bgpd=yes
EOF

cat << 'EOF' > ../frr/frr.conf
log syslog informational
router id 172.18.0.4

router bgp 64512
 bgp router-id 172.18.0.4
 neighbor 172.18.0.2 remote-as 64513
 neighbor 172.18.0.2 update-source eth0

 neighbor 172.18.0.3 remote-as 64513
 neighbor 172.18.0.3 update-source eth0

 address-family ipv4 unicast
  neighbor 172.18.0.2 activate
  neighbor 172.18.0.2 soft-reconfiguration inbound
  neighbor 172.18.0.2 route-map ACCEPT-IN in
  neighbor 172.18.0.2 route-map DENY-OUT out

  neighbor 172.18.0.3 activate
  neighbor 172.18.0.3 soft-reconfiguration inbound
  neighbor 172.18.0.3 route-map ACCEPT-IN in
  neighbor 172.18.0.3 route-map DENY-OUT out
 exit-address-family

route-map ACCEPT-IN permit 10
route-map DENY-OUT deny 10
EOF

cat << 'EOF' > ../frr/vtysh.conf
service integrated-vtysh-config
EOF

docker run -d --name frr \
    --network kind-cilium \
    -v "$(pwd)/../frr/frr.conf:/etc/frr/frr.conf" \
    -v "$(pwd)/../frr/daemons:/etc/frr/daemons" \
    -v "$(pwd)/../frr/vtysh.conf:/etc/frr/vtysh.conf" \
    --privileged \
    frrouting/frr:v8.2.2 || echo_error "Failed to start FRR container"

# -----------------------------
# Echo Server (LoadBalancer)
# -----------------------------
cat << 'EOF' > ../manifests/echo-servers.yaml
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: echo-1
  name: echo-1
spec:
  type: LoadBalancer
  ports:
  - port: 8080
    name: http
    protocol: TCP
    targetPort: 8080
  selector:
    app: echo-1
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: echo-1
  name: echo-1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: echo-1
  template:
    metadata:
      labels:
        app: echo-1
    spec:
      containers:
      - image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
        name: echo-1
        ports:
        - containerPort: 8080
EOF

kubectl apply -f ../manifests/echo-servers.yaml || echo_error "Failed to deploy echo server"

echo_success "✅ Setup complete!"
echo_success "To test DSR from another container, run:"
echo "LB_IP=$(kubectl get svc echo-1 -o jsonpath='{.status.loadBalancer.ingress[0].ip}') && \\"
echo "docker run --rm --network kind-cilium curlimages/curl curl -s http://\$LB_IP:8080"
