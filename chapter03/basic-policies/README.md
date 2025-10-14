# Basic Network Policies

This use case demonstrates fundamental Cilium network policies for controlling L3/L4 traffic between pods and services.

## Resources

- `nginx-deployment.yaml` - Sample nginx web server
- `nginx-service.yaml` - Service exposing nginx
- `netshoot-client-pod.yaml` - Authorized client pod
- `unauthorized-client.yaml` - Unauthorized client pod  
- `policy.yaml` - Basic network policy rules

## Test Flow

1. Deploy nginx server and service
2. Deploy authorized and unauthorized client pods
3. Apply network policy
4. Test connectivity from both clients
5. Verify policy enforcement

## Expected Behavior

- Authorized client should be able to reach nginx
- Unauthorized client should be blocked by policy
- Policy enforcement at L3/L4 level