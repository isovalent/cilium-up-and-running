# Chapter 7: Ingress and Gateway API

This chapter demonstrates how Cilium can expose and manage external-facing services using both traditional Kubernetes Ingress and the modern Gateway API. The examples are organized by traffic management patterns and demonstrate progressively more advanced capabilities.

## Use Cases Overview

### Ingress API
Traditional Kubernetes ingress management with Cilium as the ingress controller.

- **[ingress/http](ingress/http/)**: Basic HTTP service exposure using Ingress API
- **[ingress/tls](ingress/tls/)**: HTTPS termination with TLS certificates

### Gateway API
Next-generation traffic management using the standardized Gateway API.

- **[gateway/http](gateway/http/)**: Basic HTTP service exposure using Gateway API
- **[gateway/tls](gateway/tls/)**: HTTPS termination using Gateway API listeners
- **[gateway/matching](gateway/matching/)**: Advanced L7 traffic matching (method, headers, query params)
- **[gateway/splitting](gateway/splitting/)**: Traffic splitting and weighted routing
- **[gateway/filters](gateway/filters/)**: Header manipulation and HTTP redirects

### Service Mesh (GAMMA)
Internal service-to-service routing using Gateway API for east-west traffic.

- **[gamma](gamma/)**: GAMMA pattern for internal service mesh routing

## Quick Start

Deploy any use case using the simplified Makefile syntax:

```bash
# Basic HTTP ingress
make up chapter07 USE_CASE=ingress/http

# Gateway API with TLS
make up chapter07 USE_CASE=gateway/tls

# Advanced traffic matching
make up chapter07 USE_CASE=gateway/matching

# Traffic splitting for A/B testing
make up chapter07 USE_CASE=gateway/splitting

# Clean up
make down chapter07
```

## Prerequisites

### Gateway API CRDs
For Gateway API use cases, ensure the CRDs are installed:
```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
```

### TLS Certificates
For TLS use cases, you'll need certificates. Using mkcert for local development:
```bash
# Install mkcert
brew install mkcert  # macOS
# or download from https://github.com/FiloSottile/mkcert

# Create local CA and certificates
mkcert -install
mkcert your-domain.local "*.your-domain.local"

# Create Kubernetes secret
kubectl create secret tls your-tls-secret \
  --cert=./your-domain.local+1.pem \
  --key=./your-domain.local+1-key.pem
```

## Key Concepts

### Ingress vs Gateway API

| Feature | Ingress | Gateway API |
|---------|---------|-------------|
| **API Design** | Monolithic resource | Modular resources (Gateway, HTTPRoute) |
| **Traffic Types** | HTTP/HTTPS only | HTTP, HTTPS, gRPC, TCP, UDP |
| **Advanced Routing** | Limited, annotation-based | Native support for complex rules |
| **Multi-tenancy** | Basic namespace support | Built-in role separation |
| **Extensibility** | Controller-specific annotations | Standard filter system |
| **Configuration** | Single resource type | Separate concerns (infrastructure vs routing) |

### Traffic Management Patterns

1. **Basic Exposure**: Simple path-based routing to backend services
2. **TLS Termination**: HTTPS support with certificate management
3. **Advanced Matching**: Route based on HTTP method, headers, query parameters
4. **Traffic Splitting**: Weighted routing for canary deployments and A/B testing
5. **Request Manipulation**: Header modification and HTTP redirects
6. **East-West Routing**: Internal service-to-service traffic management

### Cilium Integration

- **Shared Load Balancer**: Multiple ingress/gateway resources can share IP addresses
- **eBPF Datapath**: High-performance traffic processing
- **Native Integration**: No additional proxy components required
- **Observability**: Built-in monitoring and tracing capabilities

## Testing Strategies

### Basic Connectivity
```bash
# Get external IP
EXTERNAL_IP=$(kubectl get gateway my-gateway -o jsonpath='{.status.addresses[0].value}')

# Test HTTP endpoint
curl http://$EXTERNAL_IP/path

# Test HTTPS endpoint (with proper certificates)
curl https://your-domain.local/path
```

### Load Distribution
```bash
# Test traffic splitting
for i in {1..20}; do
  curl http://$EXTERNAL_IP/echo
done | sort | uniq -c
```

### Header Analysis
```bash
# Check request/response headers
curl -v http://$EXTERNAL_IP/path

# Test header-based routing
curl -H "x-custom-header: value" http://$EXTERNAL_IP/path
```

## Common Configurations

### Ingress Configuration
```yaml
cilium:
  ingressController:
    enabled: true
    loadbalancerMode: shared
    default: true
```

### Gateway API Configuration
```yaml
cilium:
  gatewayAPI:
    enabled: true
```

## Troubleshooting

### Check Resource Status
```bash
# Ingress resources
kubectl get ingress
kubectl describe ingress <name>

# Gateway API resources
kubectl get gateway
kubectl get httproute
kubectl describe gateway <name>
kubectl describe httproute <name>
```

### Verify External Access
```bash
# Check external IP assignment
kubectl get svc -n kube-system cilium-gateway-<name>

# Test DNS resolution (for hostname-based routing)
nslookup your-domain.local
```

### Monitor Traffic
```bash
# Check Cilium status
cilium status

# Monitor Hubble flows
hubble observe --follow

# Check service endpoints
kubectl get endpoints
```

## Advanced Topics

- **Multi-cluster Gateway**: Gateway API across cluster boundaries
- **Rate Limiting**: Traffic throttling and quota management
- **Circuit Breaking**: Fault tolerance patterns
- **Traffic Mirroring**: Duplicate traffic for testing and analysis
- **Custom Filters**: Extending Gateway API with custom logic

Each use case directory contains detailed documentation, testing instructions, and troubleshooting guides specific to that traffic management pattern.