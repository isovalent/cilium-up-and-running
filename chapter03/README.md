# Chapter 3: Network Policies

This chapter demonstrates Cilium's network policy capabilities, covering both basic L3/L4 policies and advanced L7 policies.

## Use Cases

### Basic Policies (`basic-policies/`)
- Basic L3/L4 network policies
- Pod-to-pod communication control
- Service access restrictions

### L7 Policies (`l7-policies/`) 
- HTTP-level policy enforcement
- Application-layer security controls

## Getting Started

```bash
# Set up cluster for Chapter 3
make up CHAPTER=chapter03

# Install Cilium
make cilium-install CHAPTER=chapter03

# Test basic policies
make apply CHAPTER=chapter03 USE_CASE=basic-policies

# Test L7 policies  
make apply CHAPTER=chapter03 USE_CASE=l7-policies

# Clean up
make down
```