# IPv6-Only Networking

This use case demonstrates how to configure a Kubernetes cluster with IPv6-only networking using Cilium.

## Resources

- `kind.yaml` - Kind cluster configuration for IPv6-only networking
- `echo-deployment.yaml` - Sample application deployment
- `echo-service-ipv6.yaml` - Service configured for IPv6-only access

## Configuration

The cluster is configured with:
- IPv6 pod CIDR: `fd00:10:244::/56`
- IPv6 service CIDR: `fd00:10:96::/112`
- No IPv4 networking

## Test Flow

1. Create IPv6-only kind cluster
2. Install Cilium with IPv6-only support
3. Deploy echo application
4. Create IPv6-only service
5. Test connectivity using IPv6 addresses

## Expected Behavior

- Pods receive only IPv6 addresses
- Services are accessible only via IPv6
- DNS returns AAAA records
- All communication uses IPv6 protocol