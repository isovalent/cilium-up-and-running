# Kubernetes IPAM Mode

This use case demonstrates using Kubernetes' native IPAM instead of Cilium's built-in IPAM for pod IP address allocation.

## Resources

- `values.yaml` - Cilium configuration to use Kubernetes IPAM

## Configuration

Cilium is configured to:
- Use Kubernetes' native IPAM (`ipam.mode: kubernetes`)
- Delegate IP allocation to kube-controller-manager
- Maintain CNI functionality while using K8s IPAM

## Use Cases

- Integration with existing Kubernetes IPAM workflows
- Compliance with specific IP allocation policies
- Compatibility with other Kubernetes IPAM solutions

## Test Flow

1. Create cluster with standard kind configuration
2. Install Cilium with Kubernetes IPAM mode
3. Deploy workloads and verify IP allocation
4. Confirm IPs are allocated by Kubernetes, not Cilium

## Expected Behavior

- Pod IPs are allocated by Kubernetes controller manager
- Cilium provides networking without managing IP allocation
- Standard Kubernetes IPAM semantics apply