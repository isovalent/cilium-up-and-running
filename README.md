# Cilium Up and Running

This repository contains manifests, scripts, and configurations referenced in the O'Reilly book **_Cilium Up and Running_**. These resources are intended to help readers experiment with Cilium features, reproduce demonstrations, and deepen their understanding of Kubernetes networking, security, and observability.

> _Note: This repository is intended as a companion to the book. It is not a production-ready deployment._

## Contents

- Example Kubernetes manifests for installing and configuring Cilium
- Helm values and installation snippets
- Sample YAMLs for network policies, services, and routing scenarios
- Supporting scripts and troubleshooting utilities

Each subdirectory corresponds to a book chapter or concept and may contain its own `README.md` for instructions or explanations.

## Getting Started

To get started:

```bash
git clone https://github.com/isovalent/cilium-up-and-running.git
cd cilium-up-and-running
```

You can then browse the files and follow the instructions provided within each folder.

## Makefile Automation

This repository includes a comprehensive Makefile to streamline cluster management and Cilium deployments across chapters. The Makefile automates common tasks like creating Kind clusters, installing Cilium, and applying chapter-specific manifests.

### Validated Versions

The scripts and examples in this repository have been validated with:
- **Cilium**: v1.18.2
- **Kubernetes**: v1.34

### Quick Usage

```bash
# Create cluster and install Cilium for a specific chapter
make up CHAPTER=ch06-services
make cilium-install CHAPTER=ch06-services

# Apply chapter manifests
make apply CHAPTER=ch06-services

# Clean up
make down

# See all available targets
make help
```

The Makefile automatically detects chapter-specific configurations (kind.yaml, values.yaml) and falls back to sensible defaults, making it easy to work through the book examples consistently.

## License

This repository is licensed under the [MIT License](./LICENSE). See the [LICENSE](./LICENSE) file for details.

## Contributing

This repository is a companion to the book. If you find corrections and improvements for these examples, we welcome your suggestions via issues and PRs!

For general information on contributing to Cisco Open Source projects, please refer to the [Cisco Open Source CONTRIBUTING guide](https://github.com/cisco-open/oss-template/blob/main/CONTRIBUTING.md).

## Copyright

Copyright (c) 2025 Cisco Systems, Inc. and its affiliates.
