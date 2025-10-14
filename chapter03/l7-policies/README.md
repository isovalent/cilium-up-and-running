# L7 Network Policies

This use case demonstrates advanced Cilium network policies that operate at the HTTP application layer (L7).

## Resources

- `policy-with-l7.yaml` - HTTP-level policy enforcement

## Prerequisites

This use case builds on the basic policies. Make sure to have the nginx deployment and services from the basic-policies use case deployed first.

## Test Flow

1. Ensure basic nginx deployment is running
2. Apply L7 HTTP policy  
3. Test HTTP requests with different paths/methods
4. Verify application-layer policy enforcement

## Expected Behavior

- HTTP requests are filtered based on application-layer rules
- Policy can inspect HTTP headers, methods, and paths
- More granular control than basic L3/L4 policies