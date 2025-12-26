# Istio Multi-Cluster Setup with Kind

Local multi-cluster Istio service mesh using Kind clusters.

See [architecture.md](architecture.md) for diagrams and detailed explanation of how the mesh works.

## Prerequisites

- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries), [kubectl](https://kubernetes.io/docs/tasks/tools/), [Task](https://taskfile.dev/), [istioctl](https://istio.io/latest/docs/setup/getting-started/#download), [Podman Desktop](https://podman-desktop.io/)

## Quick Start

```bash
task # see all available tasks
task setup # setup the kind clusters and Istio multi-cluster mesh
task verify-mesh # verify connectivity across clusters
task deploy-nginx # demo to show cross-cluster service access
task kiali-setup # install Prometheus and Kiali addons for Istio
task kiali-dashboard # open the Kiali dashboard
task clean # tear down the clusters and mesh
```

## Cluster Components

**cluster1 (Primary)**
- MetalLB (LoadBalancer IPs)
- Istio control plane (istiod)
- Istio ingress gateway (NodePort 30080/30443 which get mapped to port 80/443 on the host)
- Istio east-west gateway (enable cross-cluster traffic)
- Localhost gateway (`*.localhost` routing) - relies on istio ingress gateway in place (one with the NodePorts)

**cluster2 (Remote)**
- MetalLB (LoadBalancer IPs)
- Istio remote profile (connects to cluster1's istiod)
- Istio east-west gateway (enable cross-cluster traffic)

**cluster3 (Remote)**
- MetalLB (LoadBalancer IPs)
- Istio remote profile (connects to cluster1's istiod)
- Istio east-west gateway (enable cross-cluster traffic)

## Kiali Dashboard

![Kiali Dashboard](assets/kiali-dashboard.png)


## Relevant Links

- [Istio Multi-Cluster Documentation](https://istio.io/latest/docs/setup/install/multicluster/)
- [Istio Multi-Cluster Primary Remote](https://istio.io/latest/docs/setup/install/multicluster/primary-remote/)
- [Kiali Documentation](https://kiali.io/)