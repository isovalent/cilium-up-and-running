# Chapter 6: Services and Load Balancing

This chapter explores Kubernetes services and load balancing with Cilium, comparing different approaches from traditional iptables to advanced load balancer IPAM capabilities.

## Use Cases

### iptables without Cilium (`iptables-without-cilium/`)
- Traditional Kubernetes networking with kube-proxy and iptables
- Baseline comparison for understanding Cilium improvements
- Standard cluster without CNI replacement

### Kube-Proxy Replacement (`kube-proxy-replacement/`)
- Cilium replaces kube-proxy with eBPF-based load balancing
- Higher performance and better observability
- Direct comparison with iptables approach

### Session Affinity (`session-affinity/`)
- Demonstrates session affinity (sticky sessions) with Cilium
- Client request routing to same backend pod
- Uses same infrastructure as kube-proxy replacement

### Load Balancer IPAM (`lb-ipam/`)
- **Basic** - Standard LoadBalancer service with IP pool
- **Important Pool** - Priority pool allocation
- **Start-Stop Range** - IP range with start/stop boundaries
- **No First/Last** - Pool excluding network/broadcast addresses

## Getting Started

```bash
# Test traditional iptables approach
make up chapter06 USE_CASE=iptables-without-cilium
# Note: Don't install Cilium for this use case
make apply chapter06 USE_CASE=iptables-without-cilium

# Test Cilium kube-proxy replacement
make up chapter06 USE_CASE=kube-proxy-replacement
make cilium-install chapter06 USE_CASE=kube-proxy-replacement
make apply chapter06 USE_CASE=kube-proxy-replacement

# Test session affinity
make up chapter06 USE_CASE=session-affinity
make cilium-install chapter06 USE_CASE=session-affinity
make apply chapter06 USE_CASE=session-affinity

# Test basic load balancer IPAM
make up chapter06 USE_CASE=lb-ipam/basic
make cilium-install chapter06 USE_CASE=lb-ipam/basic
make apply chapter06 USE_CASE=lb-ipam/basic

# Test different IP pool configurations
make apply chapter06 USE_CASE=lb-ipam/important-pool
make apply chapter06 USE_CASE=lb-ipam/start-stop-range
make apply chapter06 USE_CASE=lb-ipam/no-first-last

# Clean up
make down
```

## Performance Comparison

The chapter demonstrates the progression from:
1. **iptables** - Traditional but limited scalability
2. **eBPF** - High performance with Cilium kube-proxy replacement
3. **Advanced features** - Session affinity and sophisticated load balancer IPAM

## Prerequisites

- Kind for local cluster management
- Cilium CLI for service configuration
- Network testing tools for performance analysis