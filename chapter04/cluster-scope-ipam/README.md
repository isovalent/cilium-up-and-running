# Cluster Scope IPAM Mode

This use case demonstrates Cilium's cluster-scope IPAM mode for efficient IP address management across the entire cluster.

## Resources

- `values.yaml` - Cilium configuration for cluster-scope IPAM
- `nginx-deployment-10-replicas.yaml` - Large deployment for testing scalability
- `netshoot-client-pod.yaml` - Client pod for connectivity testing

## Configuration

Cilium is configured with:
- Cluster-scope IPAM mode (`ipam.mode: cluster-pool`)
- Optimized for large-scale deployments
- Efficient IP allocation across nodes
- Adequate IP pool sizes for scaling

## Test Flow

1. Create cluster with standard configuration
2. Install Cilium with cluster-scope IPAM
3. Deploy nginx with 10 replicas to test scaling
4. Deploy netshoot client for connectivity testing
5. Verify IP allocation efficiency and pod-to-pod communication

## Expected Behavior

- Efficient IP allocation across cluster nodes
- Minimal IP fragmentation
- Fast pod startup times
- Optimal IP space utilization for large deployments

## Benefits

- Better IP space utilization than per-node allocation
- Reduced IP waste in dynamic environments
- Improved scaling characteristics