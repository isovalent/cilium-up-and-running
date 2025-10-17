# Chapter 11: Network Policy Advanced Features

This chapter demonstrates three advanced network policy features in Cilium:

## Use Cases

### 1. IP Masquerading (`masquerade/`)
- **Purpose**: Control IP masquerading behavior for egress traffic
- **Files**: 
  - `kind.yaml` - Standard 3-node cluster
  - `values.yaml` - Cilium configuration for masquerading
  - `manifests/ip-masq-agent-cm.yaml` - IP masquerade agent configuration

### 2. Egress Gateway (`egress-gateway/`)
- **Purpose**: Control egress traffic routing through specific gateway nodes
- **Files**:
  - `kind.yaml` - Cluster with dedicated egress gateway nodes
  - `values.yaml` - Cilium configuration with egress gateway enabled
  - `manifests/egress-gw-policy-hr.yaml` - HR department egress policy
  - `manifests/egress-gw-policy-sales.yaml` - Sales department egress policy
  - `manifests/netshoot-client-pod.yaml` - Test client pod

### 3. Bandwidth Manager (`bandwidth-manager/`)
- **Purpose**: Manage and limit bandwidth for pods and applications
- **Files**:
  - `kind.yaml` - Standard 3-node cluster
  - `values.yaml` - Cilium configuration with bandwidth management
  - `manifests/bandwidth-manager-pods.yaml` - Pods with bandwidth annotations
  - `aks-bandwidth-manager.md` - Azure-specific instructions

## Usage Examples

```bash
# Create and configure masquerade demo
make apply CHAPTER=chapter11 USE_CASE=masquerade

# Create and configure egress gateway demo
make apply CHAPTER=chapter11 USE_CASE=egress-gateway

# Create and configure bandwidth manager demo
make apply CHAPTER=chapter11 USE_CASE=bandwidth-manager
```

Each use case is self-contained and can be run independently.