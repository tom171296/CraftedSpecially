#!/usr/bin/env bash
# Bootstraps the Argo CD root App-of-Apps for CraftedSpecially.
# Installs Argo CD if not already present, then applies the root Application.
# After this runs, all cluster changes are driven by git commits to main.
#
# Prerequisites:
#   - kubectl configured against the target AKS cluster
#   - helm v3.x installed
#
# Usage:
#   ./infra/k8s/argocd/bootstrap.sh

set -euo pipefail

ARGOCD_VERSION="7.7.16"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Creating argocd namespace..."
kubectl apply -f "${SCRIPT_DIR}/namespace.yaml"

if ! helm status argocd --namespace argocd &>/dev/null; then
  echo "==> Argo CD not found — installing (chart ${ARGOCD_VERSION})..."
  helm repo add argo https://argoproj.github.io/argo-helm --force-update
  helm repo update argo
  helm upgrade --install argocd argo/argo-cd \
    --namespace argocd \
    --version "${ARGOCD_VERSION}" \
    --values "${SCRIPT_DIR}/values.yaml" \
    --wait \
    --timeout 5m
else
  echo "==> Argo CD already installed — skipping Helm install."
fi

echo "==> Waiting for Argo CD server..."
kubectl -n argocd rollout status deployment/argocd-server --timeout=120s

echo "==> Applying root App-of-Apps..."
kubectl apply -f "${SCRIPT_DIR}/root-app.yaml"

echo ""
echo "Bootstrap complete! Argo CD is now managing all infrastructure from main."
echo ""
echo "  UI (port-forward): kubectl -n argocd port-forward svc/argocd-server 8080:80"
echo "  Admin password:    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
