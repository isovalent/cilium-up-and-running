# Geneve Encapsulation Mode

This use case demonstrates Cilium's Geneve tunneling mode, an alternative to VXLAN that provides more flexibility and extensibility.

## Resources

- `values.yaml` - Cilium configuration for Geneve encapsulation
- `netshoot-deployment.yaml` - Network debugging tool for testing connectivity
- `geneve.md` - Additional documentation for Azure AKS BYOCNI setup

## Configuration

Cilium is configured with:
- Geneve tunneling mode (`routingMode: tunnel`, `tunnelProtocol: geneve`)
- More flexible encapsulation than VXLAN
- Better support for metadata and options

## Test Flow

1. Create multi-node cluster with standard configuration
2. Install Cilium with Geneve encapsulation
3. Deploy netshoot pods for network testing
4. Test inter-node pod communication
5. Capture and analyze Geneve-encapsulated traffic

## Expected Behavior

- Pod traffic is encapsulated in Geneve headers
- Traffic flows over UDP port 6081 (default Geneve port)
- More efficient header format than VXLAN
- Support for variable-length options
- Better extensibility for future features

## Geneve vs VXLAN

**Geneve Advantages:**
- More flexible header format
- Better support for metadata
- Designed for network virtualization
- More efficient option handling
- Better future-proofing

**When to Use Geneve:**
- Cloud environments that prefer Geneve (e.g., Azure)
- Scenarios requiring custom metadata
- Future-proofing network infrastructure
- Integration with Geneve-native systems

## Cloud Integration

- **Azure**: Native support in AKS BYOCNI mode
- **OpenStack**: Geneve is the preferred encapsulation
- **OVN**: Uses Geneve as primary tunneling protocol

## Troubleshooting

- Check Geneve interfaces: `ip link show type geneve`
- Monitor Geneve traffic: `tcpdump -i any udp port 6081`
- Verify tunnel configuration: `cilium config | grep geneve`