# Cluster Scope IPAM - Small Pool (Exhaustion Demo)

This use case demonstrates what happens when Cilium's cluster-scope IPAM runs out of available IP addresses due to overly constrained CIDR allocations.

## Resources

- `values.yaml` - Cilium configuration with deliberately small IP pools
- `nginx-deployment-10-replicas.yaml` - Large deployment to trigger exhaustion
- `netshoot-client-pod.yaml` - Client pod for connectivity testing

## Configuration

Cilium is configured with very small IP pools:
- **Pool CIDRs**: `10.0.42.0/28` and `10.0.84.0/28` (16 IPs each, ~14 usable)
- **Mask Size**: `/29` (6 usable IPs per allocation)
- **Total Available**: Very limited IP space to demonstrate exhaustion

## Test Flow

1. Create cluster with standard configuration
2. Install Cilium with small cluster-scope IPAM pools
3. Deploy nginx with 10 replicas (this should exceed available IPs)
4. Observe IPAM exhaustion behavior
5. Check pod status and Cilium logs for exhaustion messages

## Expected Behavior

- **Some pods will fail to get IPs** due to exhaustion
- **Pods will be stuck in Pending state** with IP allocation errors
- **Cilium logs will show** "no more IPs available" messages
- **Demonstrates importance** of proper IPAM sizing

## Key Learning Points

- How to identify IPAM exhaustion
- Impact on pod scheduling when IPs are unavailable
- Importance of proper CIDR planning
- Monitoring and alerting on IP pool utilization

## Recovery

To fix the exhaustion:
1. Scale down the deployment: `kubectl scale deployment nginx-deployment --replicas=2`
2. Or reconfigure Cilium with larger IP pools