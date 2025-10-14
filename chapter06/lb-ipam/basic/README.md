# Load Balancer IPAM - Basic

This use case demonstrates Cilium's basic Load Balancer IP Address Management (LB-IPAM) capabilities for automatically assigning external IPs to LoadBalancer services.

## Resources

- `httpd-deployment.yaml` - Sample web application (symlink to common)
- `httpd-lb-service.yaml` - LoadBalancer service
- `lb-pool.yaml` - Basic IP pool configuration

## Configuration

- **Default Cilium installation** - Standard configuration
- **CiliumLoadBalancerIPPool** - Defines available IP range
- **LoadBalancer service** - Automatically gets IP from pool

The IP pool provides:
- **IP range** for LoadBalancer services
- **Automatic allocation** when services are created
- **Pool management** for IP lifecycle

## Test Flow

1. Create cluster with standard configuration
2. Install Cilium with default settings
3. Create IP pool for LoadBalancer services
4. Deploy httpd application
5. Create LoadBalancer service (gets IP automatically)
6. Test external connectivity to assigned IP

## Expected Behavior

- **Automatic IP assignment** from the configured pool
- **External connectivity** to the LoadBalancer IP
- **IP lifecycle management** - IPs released when service deleted
- **Pool status tracking** - Monitor IP usage

## Verification Commands

```bash
# Check IP pool status
kubectl get ciliumloadbalancerippool

# Verify service got external IP
kubectl get svc httpd-lb-service

# Test connectivity to LoadBalancer IP
curl http://<external-ip>/

# Monitor IP pool usage
kubectl describe ciliumloadbalancerippool basic-pool
```

This basic setup forms the foundation for more advanced LB-IPAM scenarios with pool prioritization and range restrictions.