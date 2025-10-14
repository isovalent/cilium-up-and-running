# Load Balancer IPAM - No First/Last

This use case demonstrates IP pool configuration that excludes the first and last addresses from allocation, following network best practices.

## Resources

- `lb-pool-no-allow-first-last.yaml` - IP pool excluding network/broadcast addresses

## Configuration

This pool is configured to:
- **Exclude first address** - Typically reserved for network address
- **Exclude last address** - Typically reserved for broadcast
- **Safe allocation** - Only assigns usable host addresses

## Test Flow

1. Apply this pool configuration
2. Create LoadBalancer services
3. Verify first and last IPs in range are never allocated
4. Confirm only safe host addresses are used

## Expected Behavior

- **Address exclusion** - First/last IPs never allocated
- **Network safety** - Avoids conflicts with network infrastructure
- **Best practices** - Follows standard IP allocation guidelines

## Use Cases

- **Network compliance** - Follows RFC standards for address allocation
- **Infrastructure safety** - Avoids conflicts with network equipment
- **Best practices** - Standard approach for production environments