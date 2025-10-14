# Dual Stack (IPv4/IPv6) Networking

This use case demonstrates how to configure a Kubernetes cluster with both IPv4 and IPv6 networking support using Cilium.

## Resources

- `kind.yaml` - Kind cluster configuration with dual-stack networking
- `echo-deployment.yaml` - Sample application deployment
- `echo-service-dualstack.yaml` - Service configured for dual-stack access

## Configuration

The cluster is configured with:
- IPv4 pod CIDR: `10.244.0.0/16`
- IPv6 pod CIDR: `fd00:10:244::/56`
- IPv4 service CIDR: `10.96.0.0/16`
- IPv6 service CIDR: `fd00:10:96::/112`

## Test Flow

1. Create dual-stack kind cluster
2. Install Cilium with dual-stack support
3. Deploy echo application
4. Create dual-stack service
5. Test connectivity on both IPv4 and IPv6

## Expected Behavior

- Pods receive both IPv4 and IPv6 addresses
- Services are accessible via both protocols
- DNS resolution works for both address families
- Inter-pod communication works over both protocols