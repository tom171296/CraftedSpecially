#!/usr/bin/env bash
# Installs the Kubernetes Gateway API standard CRDs (v1.2.1).
# Run this once against the target cluster before deploying Envoy Gateway.
#
# Usage: ./infra/k8s/install-gateway-api-crds.sh
#
# Verify after running:
#   kubectl get crd gatewayclasses.gateway.networking.k8s.io
#   kubectl get crd gateways.gateway.networking.k8s.io
#   kubectl get crd httproutes.gateway.networking.k8s.io

set -euo pipefail

GATEWAY_API_VERSION="v1.2.1"

echo "Installing Gateway API CRDs ${GATEWAY_API_VERSION}..."
kubectl apply -f "https://github.com/kubernetes-sigs/gateway-api/releases/download/${GATEWAY_API_VERSION}/standard-install.yaml"

echo "Waiting for CRDs to be established..."
kubectl wait --for=condition=Established \
  crd/gatewayclasses.gateway.networking.k8s.io \
  crd/gateways.gateway.networking.k8s.io \
  crd/httproutes.gateway.networking.k8s.io \
  --timeout=60s

echo "Gateway API CRDs installed successfully."
