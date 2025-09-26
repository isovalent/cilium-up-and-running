#!/bin/bash

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info() {
    echo -e "${YELLOW}$1${NC}"
}

echo_success() {
    echo -e "${GREEN}$1${NC}"
}

echo_info "🚀 Setting up Cilium Maglev demonstration..."

# Check prerequisites
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

if ! command -v helm &> /dev/null; then
    echo "❌ helm not found. Please install Helm first."
    exit 1
fi

if ! command -v kind &> /dev/null; then
    echo "❌ kind not found. Please install kind first."
    exit 1
fi

# Create kind cluster with 4 worker nodes
echo_info "🏗️  Creating kind cluster with 4 worker nodes..."
if kind get clusters | grep -q "^kind$"; then
    echo_info "⚠️  Kind cluster already exists. Deleting and recreating..."
    kind delete cluster
fi

kind create cluster --config kind-cluster-config.yaml

# Add Cilium Helm repo
echo_info "📦 Adding Cilium Helm repository..."
helm repo add cilium https://helm.cilium.io/ 2>/dev/null || echo_info "ℹ️  Cilium repo already exists, skipping..."
helm repo update

# Install Cilium with Maglev configuration
echo_info "🔧 Installing Cilium with Maglev configuration..."
helm upgrade --install cilium cilium/cilium \
  --version 1.18.2 \
  -f cilium-maglev-values.yaml \
  -n kube-system

# Wait for Cilium to be ready
echo_info "⏳ Waiting for Cilium to be ready..."
cilium status --wait

# Apply LoadBalancer IP Pool
echo_info "🌐 Creating LoadBalancer IP Pool..."
kubectl apply -f lb-ippool.yaml

# Apply BGP configurations
echo_info "🔄 Configuring BGP..."
kubectl apply -f bgp-peer.yaml
kubectl apply -f bgp-advertisement.yaml

# We'll apply bgp-cluster.yaml after FRR is configured with the correct IP

# Label nodes for BGP peering and backend placement
echo_info "🏷️  Labeling nodes..."
# BGP peering nodes (external-facing)
kubectl label node kind-worker3 cilium-bgp-peering=true --overwrite || true
kubectl label node kind-worker4 cilium-bgp-peering=true --overwrite || true

# Backend nodes (for workloads)
kubectl label node kind-worker maglev-backend=true --overwrite || true
kubectl label node kind-worker2 maglev-backend=true --overwrite || true

# Setup FRR (Free Range Routing) for BGP
echo_info "🔄 Setting up FRR container for BGP peering..."

# Get worker node IPs for BGP configuration
WORKER3_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-worker3)
WORKER4_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kind-worker4)

# Create FRR configuration directory
mkdir -p frr

# Create FRR daemons configuration
cat > frr/daemons << 'EOF'
zebra=yes
bgpd=yes
EOF

# Create vtysh configuration
cat > frr/vtysh.conf << 'EOF'
service integrated-vtysh-config
EOF

# Remove any existing FRR container
docker rm -f frr 2>/dev/null || true

# Start FRR container (temporarily without config to get IP)
docker run -d --name frr \
    --network kind \
    --privileged \
    frrouting/frr:v8.2.2 sleep 3600

# Get the actual FRR container IP
FRR_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' frr)
echo_info "📍 FRR container got IP: ${FRR_IP}"

# Now recreate FRR configuration with the correct IP
cat > frr/frr.conf << EOF
log syslog informational
router id ${FRR_IP}

router bgp 64512
 bgp router-id ${FRR_IP}
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

# Copy the updated configuration to the running container
docker cp frr/frr.conf frr:/etc/frr/frr.conf
docker cp frr/daemons frr:/etc/frr/daemons
docker cp frr/vtysh.conf frr:/etc/frr/vtysh.conf

# Restart FRR services to apply configuration
docker exec frr /usr/lib/frr/frrinit.sh restart

echo_info "✅ FRR container started with BGP configuration (IP: ${FRR_IP})"

# Create and apply BGP cluster configuration with correct FRR IP
echo_info "🔄 Configuring Cilium BGP cluster with FRR IP: ${FRR_IP}"
cat > bgp-cluster-dynamic.yaml << EOF
apiVersion: cilium.io/v2alpha1
kind: CiliumBGPClusterConfig
metadata:
  name: frr
spec:
  nodeSelector:
    matchLabels:
      cilium-bgp-peering: "true"
  bgpInstances:
  - name: "64513"
    localASN: 64513
    peers:
    - name: "frr"
      peerASN: 64512
      peerAddress: ${FRR_IP}
      peerConfigRef:
        name: "frr"
EOF

kubectl apply -f bgp-cluster-dynamic.yaml

# Deploy the application
echo_info "🚀 Deploying echo application..."
kubectl apply -f maglev-deployment.yaml
kubectl apply -f maglev-service.yaml

# Wait for deployment to be ready
echo_info "⏳ Waiting for deployment to be ready..."
kubectl rollout status deployment/echo

echo_success "✅ Maglev demo setup complete!"
echo_info "📋 Next steps:"
echo "   1. Check Cilium status: kubectl -n kube-system exec -it ds/cilium -- cilium-dbg status --verbose"
echo "   2. Verify Maglev algorithm: Look for 'Backend Selection: Maglev' in the output"
echo "   3. Get service IP: kubectl get svc echo-lb"
echo "   4. Test from external client with fixed source port for consistent hashing"