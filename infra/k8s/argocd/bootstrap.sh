#!/usr/bin/env bash
# One-time bootstrap script to install ArgoCD and apply the root Application.
# After this runs, all cluster changes are driven by git commits.
#
# Prerequisites:
#   - kubectl configured against the target AKS cluster
#   - helm v3.x installed
#   - SSH deploy key Secret already created (see README — Repository Access section)
#
# Usage:
#   ./infra/k8s/argocd/bootstrap.sh

set -euo pipefail

ARGOCD_VERSION="7.7.16"  # argo-cd Helm chart version
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

echo "==> Creating argocd namespace..."
kubectl apply -f "${SCRIPT_DIR}/namespace.yaml"

echo "==> Adding Argo Helm repo..."
helm repo add argo https://argoproj.github.io/argo-helm --force-update
helm repo update argo

echo "==> Installing ArgoCD (chart version ${ARGOCD_VERSION})..."
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --version "${ARGOCD_VERSION}" \
  --values "${SCRIPT_DIR}/values.yaml" \
  --wait \
  --timeout 5m

echo "==> Waiting for ArgoCD server to be ready..."
kubectl -n argocd rollout status deployment/argocd-server --timeout=120s

echo "==> Applying root App-of-Apps..."
kubectl apply -f "${SCRIPT_DIR}/root-app.yaml"

echo ""
echo "Bootstrap complete!"
echo ""
echo "ArgoCD is now managing all infrastructure in infra/k8s/."
echo ""
echo "Access the UI (port-forward):"
echo "  kubectl -n argocd port-forward svc/argocd-server 8080:80"
echo "  Open: http://localhost:8080"
echo ""
echo "Get the initial admin password:"
echo "  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
