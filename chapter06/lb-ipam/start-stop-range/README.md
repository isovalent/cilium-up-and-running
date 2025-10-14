# Load Balancer IPAM - Start/Stop Range

This use case demonstrates IP pool configuration with specific start and stop addresses, providing precise control over the usable IP range.

## Resources

- `lb-pool-start-stop.yaml` - IP pool with defined start/stop boundaries

## Configuration

This pool defines:
- **Explicit start address** - First usable IP in the range
- **Explicit stop address** - Last usable IP in the range
- **Precise boundaries** - Exact control over allocation range

## Test Flow

1. Apply this pool configuration
2. Create multiple LoadBalancer services
3. Verify IPs are allocated within the defined range
4. Test behavior when range is exhausted

## Expected Behavior

- **Range enforcement** - IPs only allocated between start/stop
- **Sequential allocation** - IPs assigned in order within range
- **Range exhaustion** - Clear behavior when no IPs available

## Use Cases

- **Network compliance** - Specific IP ranges required by policy
- **Firewall rules** - Simplified rules with predictable ranges
- **IP planning** - Precise control for network architecture