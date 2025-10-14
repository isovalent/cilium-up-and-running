# VXLAN Encapsulation Mode

This use case demonstrates Cilium's default VXLAN tunneling mode for inter-node pod communication in environments that don't support native routing.

## Resources

- `netshoot-deployment.yaml` - Network debugging tool for testing connectivity

## Configuration

Cilium uses default VXLAN configuration:
- VXLAN tunneling for inter-node communication (`routingMode: tunnel`, `tunnelProtocol: vxlan`)
- Overlay network that works in any environment
- Encapsulation handles routing between nodes

## Test Flow

1. Create multi-node cluster with standard configuration
2. Install Cilium with default VXLAN settings
3. Deploy netshoot pods for network testing
4. Test inter-node pod communication
5. Capture and analyze VXLAN-encapsulated traffic

## Expected Behavior

- Pod traffic is encapsulated in VXLAN headers
- Traffic flows over UDP port 8472 (default VXLAN port)
- Works regardless of underlying network topology
- Automatic tunnel establishment between nodes
- Transparent overlay networking for pods

## VXLAN Details

- **VNI (VXLAN Network Identifier)**: Used to isolate different networks
- **VTEP (VXLAN Tunnel Endpoint)**: Cilium agents act as VTEPs
- **UDP Encapsulation**: Original packet wrapped in UDP/VXLAN headers
- **MAC Learning**: Automatic discovery of remote VTEP endpoints

## Use Cases

- Cloud environments without native pod routing
- On-premises networks with limited routing control
- Multi-tenant environments requiring network isolation
- Default choice for most Kubernetes deployments

## Troubleshooting

- Check VXLAN interfaces: `ip link show type vxlan`
- Monitor VXLAN traffic: `tcpdump -i any udp port 8472`
- Verify tunnel endpoints: `cilium bpf tunnel list`