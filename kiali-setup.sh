#!/bin/bash

set -e

echo "Installing Prometheus and Kiali for Istio 1.28..."

# Pull and load images into kind cluster1
echo "Pulling and loading images into kind cluster1..."

docker image inspect quay.io/kiali/kiali:v2.17 > /dev/null 2>&1 || docker pull quay.io/kiali/kiali:v2.17
docker image inspect ghcr.io/prometheus-operator/prometheus-config-reloader:v0.85.0 > /dev/null 2>&1 || docker pull ghcr.io/prometheus-operator/prometheus-config-reloader:v0.85.0
docker image inspect docker.io/prom/prometheus:v3.5.0 > /dev/null 2>&1 || docker pull docker.io/prom/prometheus:v3.5.0

kind load docker-image quay.io/kiali/kiali:v2.17 --name cluster1
kind load docker-image ghcr.io/prometheus-operator/prometheus-config-reloader:v0.85.0 --name cluster1
kind load docker-image docker.io/prom/prometheus:v3.5.0 --name cluster1

# Apply Prometheus
echo "Applying Prometheus..."
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.28/samples/addons/prometheus.yaml --context kind-cluster1

# Apply Kiali
echo "Applying Kiali..."
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.28/samples/addons/kiali.yaml --context kind-cluster1

# Wait for pods to be ready
echo "Waiting for Prometheus to be ready..."
kubectl rollout status deployment/prometheus -n istio-system --context kind-cluster1 --timeout=120s

echo "Waiting for Kiali to be ready..."
kubectl rollout status deployment/kiali -n istio-system --context kind-cluster1 --timeout=120s

echo "Kiali setup complete!"
echo "Run task kiali-dashboard to access the Kiali dashboard."


