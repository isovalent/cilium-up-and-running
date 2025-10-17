# Chapter 8: Advanced Load Balancing

This chapter demonstrates advanced load balancing capabilities in Cilium, including different algorithms, protocols, and optimization techniques.

## Use Cases

### DSR (Direct Server Return)
- **[dsr/](dsr/)**: Direct Server Return mode for optimized load balancing

### LRP (Local Redirect Policy) 
- **[lrp/](lrp/)**: Local node traffic handling and DNS optimization

### Maglev
- **[maglev/](maglev/)**: Maglev consistent hashing load balancing algorithm

### STB (Socket-based Load Balancing)
- **[stb/](stb/)**: Socket-based load balancing for high performance

## Quick Start

Deploy any use case using the Makefile:

```bash
# Deploy DSR load balancing
make up chapter08 USE_CASE=dsr

# Deploy Maglev hashing
make up chapter08 USE_CASE=maglev

# Deploy LRP for local traffic
make up chapter08 USE_CASE=lrp

# Deploy socket-based load balancing
make up chapter08 USE_CASE=stb

# Clean up
make down chapter08
```

## Key Concepts

- **Load Balancing Algorithms**: Different algorithms for traffic distribution
- **Performance Optimization**: Techniques to improve throughput and latency
- **Traffic Locality**: Keeping traffic local to nodes when possible
- **Consistent Hashing**: Stable backend selection across topology changes