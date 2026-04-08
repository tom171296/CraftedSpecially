## Why

Kubernetes resources (cert-manager, Envoy Gateway, HTTPRoutes) are currently deployed manually via `kubectl` and `helm` commands, creating drift risk and no audit trail. Adopting GitOps with ArgoCD makes the cluster state fully declarative, version-controlled, and self-healing — aligning infrastructure with the same practices used for application code.

## What Changes

- **New**: ArgoCD installed in the cluster as the GitOps controller
- **New**: ArgoCD `Application` manifests for each component (cert-manager, Envoy Gateway, Gateway API CRDs, HTTPRoutes)
- **New**: `infra/k8s/argocd/` directory containing ArgoCD installation values and App definitions
- **New**: App-of-Apps pattern to bootstrap all applications from a single root Application
- **Modified**: Existing Helm values files and raw manifests in `infra/k8s/` become the source of truth read by ArgoCD (no structural changes, just ownership transfers)
- **Removed**: Manual `kubectl apply` / `helm upgrade --install` steps from the README operational workflow

## Capabilities

### New Capabilities

- `argocd-bootstrap`: Install ArgoCD into the cluster and configure it to watch the repository
- `app-of-apps`: Root ArgoCD Application that manages all child Application definitions, enabling one-command full-cluster bootstrap
- `gitops-sync-policy`: Automated sync policies (self-heal, prune) defined per application so the cluster continuously reconciles to git state

### Modified Capabilities

<!-- No existing spec-level requirements are changing — this is a new delivery mechanism for the same runtime behavior -->

## Impact

- **`infra/k8s/`**: New `argocd/` subdirectory added; existing manifests unchanged but now owned by ArgoCD
- **`infra/k8s/README.md`**: Operational runbook updated — manual steps replaced by ArgoCD bootstrap procedure
- **CI/CD**: No application build pipeline changes; cluster state changes are driven by git pushes
- **Cluster**: Requires ArgoCD namespace and CRDs; existing workloads unaffected during migration
- **Security**: ArgoCD needs read access to the git repository (deploy key or GitHub App)
