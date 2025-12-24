# Istio Multi-Cluster Setup with Kind

Local multi-cluster Istio service mesh using Kind clusters.

## Prerequisites

- [Kind](https://kind.sigs.k8s.io/), [kubectl](https://kubernetes.io/docs/tasks/tools/), [Task](https://taskfile.dev/), [istioctl](https://istio.io/latest/docs/setup/getting-started/#download)
- Podman or Docker

## Quick Start

```bash
task install-istioctl  # if needed
task setup
task verify-mesh
task deploy-nginx      # optional demo
```

## Commands

Run `task --list-all` for all commands. Key ones:

- `task setup` - Full multi-cluster setup
- `task verify-mesh` - Check connectivity
- `task clean` - Tear down everything
