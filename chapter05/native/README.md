# Native Routing Mode

This use case demonstrates Cilium's native routing mode, where pod-to-pod communication across nodes happens without encapsulation using direct host routes.

## Resources

- `values.yaml` - Cilium configuration for native routing with auto node routes
- `kind.yaml` - Kind cluster configuration (may need special network setup)

## Configuration

Cilium is configured with:
- Native routing mode (`routingMode: native`)
- Auto node routes enabled (`autoDirectNodeRoutes: true`)
- No tunneling or encapsulation
- Direct IP routing between nodes

## Test Flow

1. Create multi-node cluster with appropriate network configuration
2. Install Cilium with native routing mode
3. Deploy test pods across different nodes
4. Test inter-node pod communication
5. Verify direct routing without encapsulation

## Expected Behavior

- Pod traffic routes directly through host network
- No VXLAN/Geneve headers in packet traces
- Lower CPU overhead compared to tunneling
- Host routing tables contain pod CIDR routes
- Direct L3 communication between nodes

## Network Requirements

- Underlying network must support pod CIDR routing
- Nodes must be able to route to each other's pod CIDRs
- May require cloud provider route table configuration
- Works best in environments with BGP or static routing

## Benefits

- Better performance (no encap/decap overhead)
- Simpler troubleshooting with standard networking tools
- Native integration with existing network infrastructure
- Lower MTU requirements