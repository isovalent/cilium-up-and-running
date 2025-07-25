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

echo "Starting Cilium setup..."

if [ ! -d "cilium" ]; then
    git clone https://github.com/cilium/cilium || echo_error "Failed to clone Cilium repository"
fi

cd cilium
sysctl fs.inotify.max_user_instances=1024
bash contrib/scripts/kind.sh --xdp 1 4 || echo_error "Failed to create kind cluster"

echo "Waiting for kind cluster to be ready..."
mkdir -p ../manifests ../frr

helm repo add cilium https://helm.cilium.io/ || echo_error "Failed to add Cilium helm repo"
helm repo update

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

WORKER3_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-worker3)
WORKER4_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-worker4)

cat <<EOF > ../manifests/bgp-cluster.yaml
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
      peerAddress: 172.18.0.7
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

# Label nodes
kubectl label node kind-worker3 cilium-bpg-peering=true maglev-backend=true || echo_error "Failed to label kind-worker3"
kubectl label node kind-worker4 cilium-bpg-peering=true maglev-backend=true || echo_error "Failed to label kind-worker4"

# Deploy echo-server on maglev-backend nodes
cat << 'EOF' > ../manifests/echo-server.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-server
  labels:
    app: echo-server
spec:
  replicas: 2
  selector:
    matchLabels:
      app: echo-server
  template:
    metadata:
      labels:
        app: echo-server
    spec:
      nodeSelector:
        maglev-backend: "true"
      containers:
        - name: echo-server
          image: gcr.io/kubernetes-e2e-test-images/echoserver:2.2
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: echo-server
spec:
  selector:
    app: echo-server
  ports:
    - name: http
      port: 8080
      targetPort: 8080
  type: LoadBalancer
EOF

kubectl apply -f ../manifests/echo-server.yaml || echo_error "Failed to deploy echo-server"

# FRR config
cat <<EOF > ../frr/daemons
zebra=yes
bgpd=yes
EOF

cat <<EOF > ../frr/frr.conf
log syslog informational
router id 172.18.0.7

router bgp 64512
 bgp router-id 172.18.0.7
 neighbor ${WORKER3_IP} remote-as 64513
 neighbor ${WORKER3_IP} update-source eth0

 neighbor ${WORKER4_IP} remote-as 64513
 neighbor ${WORKER4_IP} update-source eth0

 address-family ipv4 unicast
  neighbor ${WORKER3_IP} activate
  neighbor ${WORKER3_IP} soft-reconfiguration inbound
  neighbor ${WORKER3_IP} route-map ACCEPT-IN in
  neighbor ${WORKER3_IP} route-map DENY-OUT out

  neighbor ${WORKER4_IP} activate
  neighbor ${WORKER4_IP} soft-reconfiguration inbound
  neighbor ${WORKER4_IP} route-map ACCEPT-IN in
  neighbor ${WORKER4_IP} route-map DENY-OUT out
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

echo_success "✅ Setup complete!"
