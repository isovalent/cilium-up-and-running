# Multi-Pool IPAM Mode

This use case demonstrates Cilium's multi-pool IPAM capability, allowing different IP pools for different namespaces or workload types.

## Resources

- `values.yaml` - Cilium configuration for multi-pool IPAM
- `namespaces.yaml` - Test namespaces (acme and foobar)
- `acme-pool.yaml` - IP pool for acme namespace
- `foobar-pool.yaml` - IP pool for foobar namespace
- `pod1.yaml` - Pod deployed in acme namespace
- `pod2.yaml` - Pod deployed in foobar namespace

## Configuration

This setup creates:
- Multiple IP pools with different CIDR ranges
- Namespace-specific IP allocation policies
- Pool selection based on namespace labels

## Test Flow

1. Create cluster with standard configuration
2. Install Cilium with multi-pool IPAM support
3. Create test namespaces with appropriate labels
4. Deploy IP pools for each namespace
5. Deploy pods in different namespaces
6. Verify pods get IPs from their designated pools

## Expected Behavior

- Pods in `acme` namespace get IPs from acme pool
- Pods in `foobar` namespace get IPs from foobar pool
- IP allocation respects pool boundaries
- Network policies can be applied per pool

## Use Cases

- Multi-tenant environments
- Regulatory compliance requiring IP segregation
- Different security zones within the same cluster
- Integration with external IP management systems