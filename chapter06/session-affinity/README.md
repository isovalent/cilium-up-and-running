# Session Affinity (Sticky Sessions)

This use case demonstrates Cilium's session affinity capabilities, ensuring client requests are consistently routed to the same backend pod.

## Resources

- `kind.yaml` - Shared with kube-proxy replacement (symlink)
- `values.yaml` - Shared Cilium configuration (symlink)
- `affinity-deployment.yaml` - Multi-replica application deployment
- `httpd-lb-service.yaml` - LoadBalancer service with session affinity

## Configuration

Uses the same Cilium configuration as kube-proxy replacement:
- **Kube-proxy replacement enabled**
- **eBPF-based load balancing**
- **Session affinity support** via service configuration

The service is configured with:
- **SessionAffinity: ClientIP** - Routes based on client IP
- **LoadBalancer type** - External access capability
- **Multiple backend pods** - Demonstrates sticky routing

## Test Flow

1. Create cluster with kube-proxy replacement configuration
2. Install Cilium with kube-proxy replacement
3. Deploy multi-replica httpd application
4. Create service with session affinity enabled
5. Test that requests from same client go to same pod
6. Verify session stickiness behavior

## Expected Behavior

- **Consistent routing** - Same client IP always hits same pod
- **Session persistence** - Maintained across multiple requests
- **Load distribution** - Different clients get different pods
- **Failover handling** - Graceful handling when target pod fails

## Testing Commands

```bash
# Test session affinity from different sources
kubectl exec netshoot-client -- curl -s http://service-ip/ | grep hostname
kubectl exec netshoot-client -- curl -s http://service-ip/ | grep hostname
kubectl exec netshoot-client -- curl -s http://service-ip/ | grep hostname

# Check service endpoints
kubectl get endpoints httpd-lb-service

# Monitor which pods receive traffic
cilium monitor --type l3_l4 | grep httpd
```

## Session Affinity Options

- **ClientIP** - Route based on source IP address
- **None** - No affinity (default round-robin)
- **SessionAffinityConfig** - Configure timeout and behavior

## Use Cases

- **Stateful applications** - Applications that maintain client state
- **Shopping carts** - E-commerce session management
- **User preferences** - Personalized application state
- **Legacy applications** - Apps not designed for stateless operation