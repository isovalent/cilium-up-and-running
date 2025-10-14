# Intra-Node Communication

This use case demonstrates how pods communicate when they are scheduled on the same Kubernetes node, showing the simplest datapath scenario.

## Resources

- `intra-node-example.yaml` - Pod configuration that forces scheduling on the same node

## Configuration

- Uses standard Cilium configuration
- Demonstrates local veth pair communication
- No encapsulation or inter-node routing required

## Test Flow

1. Create cluster with standard kind configuration
2. Install Cilium with default settings
3. Deploy pods configured to run on the same node
4. Test communication between co-located pods
5. Analyze traffic flow using network tools

## Expected Behavior

- Pods are scheduled on the same node
- Traffic flows through local veth pairs
- No tunneling or encapsulation occurs
- Direct container-to-container communication
- Lowest latency communication path

## Learning Points

- Understanding veth pair networking
- Container network namespace isolation
- Local traffic routing within a node
- Foundation for understanding more complex datapaths