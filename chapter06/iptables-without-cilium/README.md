# iptables without Cilium

This use case demonstrates traditional Kubernetes networking using kube-proxy and iptables, providing a baseline for comparison with Cilium's eBPF-based approach.

## Resources

- `kind.yaml` - Kind cluster configuration without CNI (no Cilium)
- `httpd-deployment.yaml` - Sample web application
- `httpd-service.yaml` - ClusterIP service using iptables

## Configuration

- **No CNI installed** - Uses traditional networking
- **kube-proxy enabled** - Standard iptables-based load balancing
- **iptables rules** - Service load balancing via netfilter

## Test Flow

1. Create cluster without Cilium CNI
2. Deploy httpd application and service
3. Test service connectivity
4. Examine iptables rules created by kube-proxy
5. Monitor performance characteristics

## Expected Behavior

- **iptables rules** generated for each service
- **DNAT/SNAT** based load balancing
- **Linear performance degradation** with scale
- **Limited observability** into traffic flows

## Analysis Commands

```bash
# View iptables rules for services
sudo iptables -t nat -L -n -v

# Check kube-proxy status
kubectl get pods -n kube-system -l k8s-app=kube-proxy

# Monitor iptables rule count
sudo iptables -t nat -L | wc -l
```

## Limitations

- **Performance** - iptables processing overhead
- **Scalability** - Rule count grows linearly with services
- **Observability** - Limited visibility into traffic flows
- **Features** - Basic load balancing capabilities only

This baseline helps understand why Cilium's eBPF approach provides significant improvements.