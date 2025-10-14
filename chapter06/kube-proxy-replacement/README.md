# Kube-Proxy Replacement

This use case demonstrates Cilium's eBPF-based replacement for kube-proxy, providing higher performance and better observability for Kubernetes services.

## Resources

- `kind.yaml` - Kind cluster configuration
- `values.yaml` - Cilium configuration with kube-proxy replacement enabled
- `httpd-deployment.yaml` - Sample web application
- `httpd-service.yaml` - ClusterIP service using eBPF
- `netshoot-client.yaml` - Client pod for testing connectivity

## Configuration

Cilium is configured with:
- **Kube-proxy replacement** (`kubeProxyReplacement: true`)
- **eBPF-based load balancing** - Direct kernel data path
- **Socket-level load balancing** - Optimized connection handling
- **Enhanced observability** - Flow visibility and metrics

## Test Flow

1. Create cluster with standard configuration
2. Install Cilium with kube-proxy replacement
3. Deploy httpd application and service
4. Deploy netshoot client for testing
5. Test service connectivity and performance
6. Compare with iptables baseline

## Expected Behavior

- **No iptables rules** for services (eBPF handles load balancing)
- **Better performance** - Lower latency and higher throughput
- **Constant performance** - No degradation with service count
- **Rich observability** - Flow logs and connection tracking

## Analysis Commands

```bash
# Verify no iptables rules for services
sudo iptables -t nat -L -n | grep -i cilium

# Check Cilium service map
cilium bpf lb list

# Monitor service connections
cilium monitor --type l3_l4

# View service endpoints
cilium service list
```

## Performance Benefits

- **50%+ latency reduction** compared to iptables
- **Constant performance** regardless of service count
- **CPU efficiency** - Lower overhead per connection
- **Memory efficiency** - No linear rule growth

## Observability Improvements

- **Flow visibility** - See actual traffic patterns
- **Connection tracking** - Monitor established connections
- **Service metrics** - Per-service performance data
- **Real-time monitoring** - Live traffic analysis