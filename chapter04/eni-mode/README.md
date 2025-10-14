# ENI Mode IPAM

This use case demonstrates Cilium's AWS ENI (Elastic Network Interface) IPAM mode for EKS clusters.

## Resources

- `values.yaml` - Cilium configuration for ENI IPAM mode
- `eks-config.yaml` - EKS cluster configuration example

## Configuration

Cilium is configured to:
- Use AWS ENI IPAM (`ipam.mode: eni`)
- Integrate with AWS VPC networking
- Leverage native AWS IP address management
- Optimize for EKS performance characteristics

## Prerequisites

- AWS EKS cluster
- Proper IAM permissions for ENI management
- VPC with sufficient IP addresses
- EC2 instances with ENI support

## Test Flow

1. Create EKS cluster using provided configuration
2. Install Cilium with ENI IPAM mode
3. Deploy workloads
4. Verify pods receive VPC IP addresses
5. Test connectivity within VPC

## Expected Behavior

- Pods receive IP addresses from VPC subnets
- Direct VPC connectivity without overlay
- Native AWS networking performance
- Integration with AWS security groups
- Support for AWS Load Balancer Controller

## Benefits

- Native AWS networking performance
- No encapsulation overhead
- Direct integration with AWS services
- Simplified network troubleshooting
- Support for AWS security features