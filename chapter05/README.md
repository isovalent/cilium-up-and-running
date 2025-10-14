# Chapter 5: The Datapath

This chapter explores Cilium's different datapath modes and routing mechanisms, demonstrating how traffic flows through the network in different configurations.

## Use Cases

### Intra-Node Communication (`intra-node/`)
- Demonstrates pod-to-pod communication within the same node
- Shows how traffic flows without leaving the host
- Container veth pair and routing

### Native Routing (`native/`)
- Native routing without encapsulation
- Direct routing between nodes using host routes
- Requires underlying network to support pod CIDR routing

### VXLAN Encapsulation (`vxlan/`)
- Default tunneling mode using VXLAN
- Overlay networking for environments without native routing support
- Works in most network environments

### Geneve Encapsulation (`geneve/`)
- Alternative tunneling using Geneve protocol
- More flexible and extensible than VXLAN
- Particularly useful in cloud environments like Azure

## Getting Started

```bash
# Test intra-node communication
make up chapter05 USE_CASE=intra-node
make cilium-install chapter05 USE_CASE=intra-node
make apply chapter05 USE_CASE=intra-node

# Test native routing
make up chapter05 USE_CASE=native
make cilium-install chapter05 USE_CASE=native
make apply chapter05 USE_CASE=native

# Test VXLAN encapsulation
make up chapter05 USE_CASE=vxlan
make cilium-install chapter05 USE_CASE=vxlan
make apply chapter05 USE_CASE=vxlan

# Test Geneve encapsulation
make up chapter05 USE_CASE=geneve
make cilium-install chapter05 USE_CASE=geneve
make apply chapter05 USE_CASE=geneve

# Clean up
make down
```

## Prerequisites

- Kind for local cluster management
- Cilium CLI for datapath configuration
- Network analysis tools (tcpdump, netshoot) for traffic inspection