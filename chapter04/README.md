# Chapter 4: IP Address Management

This chapter demonstrates Cilium's comprehensive IP Address Management (IPAM) capabilities, covering different modes and configurations for various network scenarios.

## Use Cases

### IPv4 and IPv6 Support (`ipv4-ipv6-support/`)
- **Dual Stack (IPv4/IPv6)** - Configure clusters with both IPv4 and IPv6 support
- **Single Stack (IPv6 only)** - IPv6-only cluster configuration

### Kubernetes IPAM (`kubernetes-ipam/`)
- Use Kubernetes' native IPAM for pod IP allocation

### Cluster Scope IPAM (`cluster-scope-ipam/`)
- Cluster-wide IP pool management and allocation
- Scalability testing with multiple pod replicas

### Cluster Scope IPAM - Small Pool (`cluster-scope-ipam-small/`)
- Demonstration of IPAM exhaustion with constrained IP pools
- Learning how to identify and troubleshoot IP allocation failures

### Multi-Pool IPAM (`multi-pool-ipam/`)
- Multiple IP pools with namespace-specific allocation
- Pool-based IP management strategies

### ENI Mode (`eni-mode/`)
- AWS ENI-based IPAM for EKS clusters
- Cloud-native IP address management

## Getting Started

```bash
# Basic cluster setup with default IPAM
make up chapter04
make cilium-install chapter04

# Test dual-stack networking
make up chapter04 USE_CASE=ipv4-ipv6-support/dual-stack
make cilium-install chapter04 USE_CASE=ipv4-ipv6-support/dual-stack
make apply chapter04 USE_CASE=ipv4-ipv6-support/dual-stack

# Test cluster-scope IPAM (normal)
make up chapter04 USE_CASE=cluster-scope-ipam
make cilium-install chapter04 USE_CASE=cluster-scope-ipam
make apply chapter04 USE_CASE=cluster-scope-ipam

# Test cluster-scope IPAM exhaustion
make up chapter04 USE_CASE=cluster-scope-ipam-small
make cilium-install chapter04 USE_CASE=cluster-scope-ipam-small
make apply chapter04 USE_CASE=cluster-scope-ipam-small

# Clean up
make down
```

## Backward Compatibility

For users following the book directly, the original configuration files are still available:
- `cilium-ipam-cluster-scope-small.yaml` - Available at chapter root level

## Prerequisites

- Kind for local cluster management
- Cilium CLI for IPAM configuration
- kubectl for resource management