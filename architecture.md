# Istio Multi-Cluster Mesh Architecture

## Overview

This POC demonstrates a **primary-remote** Istio multi-cluster topology using Kind clusters with different networks. One primary cluster (cluster1) hosts the control plane, while two remote clusters (cluster2, cluster3) connect to it.

```mermaid
flowchart TB
    subgraph "Kind Network (podman)"
        subgraph cluster1["cluster1 (Primary)"]
            istiod["istiod"]
            ingress["ingress-gateway\n:80/:443"]
            ew1["east-west-gateway"]
            hw1["helloworld-v1"]
        end

        subgraph cluster2["cluster2 (Remote)"]
            ew2["east-west-gateway"]
            hw2["helloworld-v2"]
            nginx2["nginx"]
        end

        subgraph cluster3["cluster3 (Remote)"]
            ew3["east-west-gateway"]
            hw3["helloworld-v3"]
            nginx3["nginx-alt"]
        end
    end

    browser["Browser"]

    %% Control plane
    istiod -.->|"config"| ew1
    ew1 -.->|"15012"| ew2
    ew1 -.->|"15012"| ew3

    %% Data plane
    ew1 <-->|"15443\nmTLS"| ew2
    ew1 <-->|"15443\nmTLS"| ew3

    %% Ingress
    browser -->|"*.localhost"| ingress
    ingress --> hw1
    ingress -.->|"via east-west"| hw2
    ingress -.->|"via east-west"| hw3
    ingress -.->|"via east-west"| nginx2
    ingress -.->|"via east-west"| nginx3
```

## Traffic Flows

### Control Plane (cluster1 → remote clusters)

```mermaid
sequenceDiagram
    participant istiod as istiod (cluster1)
    participant ew1 as east-west-gw (cluster1)
    participant ew2 as east-west-gw (cluster2/3)
    participant proxy as Envoy Sidecar

    istiod->>ew1: xDS config (15012)
    ew1->>ew2: TLS passthrough
    ew2->>proxy: Deliver config
```

### Data Plane (cross-cluster request)

```mermaid
sequenceDiagram
    participant curl as curl (any cluster)
    participant ew1 as east-west-gw (cluster1)
    participant ew2 as east-west-gw (remote)
    participant svc as Remote Service

    curl->>ew1: mTLS request
    ew1->>ew2: Port 15443 (AUTO_PASSTHROUGH)
    ew2->>svc: Forward to service
    svc-->>curl: Response
```

### Browser Access

```mermaid
sequenceDiagram
    participant browser as Browser
    participant ingress as Ingress Gateway
    participant app as Service (any cluster)

    browser->>ingress: http://*.localhost
    ingress->>app: Route (local or via east-west)
    app-->>browser: Response
```

## Key Components

| Component | Cluster | Purpose |
|-----------|---------|---------|
| **istiod** | cluster1 | Control plane for all clusters |
| **istio-ingressgateway** | cluster1 | Browser access (NodePort 30080/30443) |
| **istio-eastwestgateway** | all | Cross-network traffic + control plane |
| **MetalLB** | all | LoadBalancer IPs for gateways |

## Network Configuration

| Cluster | Network | Role | MetalLB Range |
|---------|---------|------|---------------|
| cluster1 | network1 | Primary | .200-.220 |
| cluster2 | network2 | Remote | .221-.240 |
| cluster3 | network3 | Remote | .241-.250 |

## Browser URLs

| URL | Destination |
|-----|-------------|
| `http://helloworld.localhost/hello` | Load balanced across v1, v2, v3 |
| `http://nginx.localhost` | cluster2 only |
| `http://nginx-alt.localhost` | cluster3 only |
