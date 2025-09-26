#!/bin/bash

# Cleanup script for Cilium Maglev demonstration
# Removes kind cluster and cleans up resources

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo_info() {
    echo -e "${YELLOW}$1${NC}"
}

echo_success() {
    echo -e "${GREEN}$1${NC}"
}

echo_error() {
    echo -e "${RED}$1${NC}"
}

echo_info "🧹 Cleaning up Cilium Maglev demonstration..."

# Check if kind is available
if ! command -v kind &> /dev/null; then
    echo_error "❌ kind not found. Cannot cleanup kind cluster."
    exit 1
fi

# Delete kind cluster
echo_info "🗑️  Deleting kind cluster..."
if kind get clusters | grep -q "^kind$"; then
    kind delete cluster
    echo_success "✅ Kind cluster deleted successfully"
else
    echo_info "ℹ️  No kind cluster found to delete"
fi

# Clean up any Docker containers that might be left over
echo_info "🐳 Cleaning up Docker containers..."
if docker ps -a --format "table {{.Names}}" | grep -q "^frr$"; then
    echo_info "🗑️  Removing FRR container..."
    docker rm -f frr || echo_info "ℹ️  FRR container already removed"
else
    echo_info "ℹ️  No FRR container found"
fi

# Clean up any Docker networks that might be left over
echo_info "🌐 Cleaning up Docker networks..."
if docker network ls --format "table {{.Name}}" | grep -q "^kind$"; then
    echo_info "🗑️  Removing kind network..."
    docker network rm kind || echo_info "ℹ️  Network already removed or in use"
else
    echo_info "ℹ️  No kind network found"
fi

# Clean up FRR configuration directory
echo_info "📁 Cleaning up FRR configuration..."
if [ -d "frr" ]; then
    echo_info "🗑️  Removing FRR configuration directory..."
    rm -rf frr
    echo_success "✅ FRR configuration directory removed"
else
    echo_info "ℹ️  No FRR configuration directory found"
fi

# Optional: Clean up Helm repositories (uncomment if desired)
# echo_info "📦 Removing Cilium Helm repository..."
# helm repo remove cilium || echo_info "ℹ️  Cilium repo not found or already removed"

echo_success "🎉 Cleanup complete!"
echo_info "📋 All resources have been cleaned up:"
echo "   ✅ Kind cluster deleted"
echo "   ✅ Docker containers removed" 
echo "   ✅ Docker networks cleaned up"
echo "   ✅ FRR configuration directory removed"
echo ""
echo_info "💡 You can now run './setup-maglev.sh' again to recreate the demo environment"