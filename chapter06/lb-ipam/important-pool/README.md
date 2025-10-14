# Load Balancer IPAM - Important Pool

This use case demonstrates priority-based IP pool allocation, where certain services can be assigned IPs from high-priority pools.

## Resources

- `lb-pool-important.yaml` - High-priority IP pool configuration

## Configuration

This pool is configured with:
- **Higher priority** than basic pools
- **Reserved IP range** for important services
- **Preferential allocation** for critical workloads

## Test Flow

1. Apply this pool configuration after basic setup
2. Create LoadBalancer services with priority labels/annotations
3. Verify important services get IPs from priority pool
4. Test that regular services still use basic pool

## Expected Behavior

- **Priority allocation** - Important services get preferred IPs
- **Fallback behavior** - Regular services use standard pools
- **Pool exhaustion handling** - Graceful degradation when priority pool full

## Use Cases

- **Production services** - Critical applications get priority IPs
- **External-facing services** - Customer-facing apps get premium ranges
- **SLA differentiation** - Different service levels get different IP ranges