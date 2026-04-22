## Why

CraftedSpecially has a built container image and an AKS cluster with Argo CD, but the image is pushed to GHCR and there are no Kubernetes manifests or Argo CD application to actually deploy the workload. The cluster cannot run the application until this gap is closed.

## What Changes

- Update CI workflow to authenticate to Azure Container Registry and push the built image there instead of (or in addition to) GHCR
- Add Kubernetes deployment manifests (`Deployment`, `Service`) for the CraftedSpecially API under `infra/k8s/crafted-specially/`
- Add an Argo CD `Application` resource under `infra/k8s/argocd/apps/` so the root app picks up and deploys the workload
- Grant the AKS workload identity (kubelet identity) the `AcrPull` role on the ACR — this role assignment is already defined in the AKS Bicep module, so no infrastructure change is required

## Capabilities

### New Capabilities

- `container-image-to-acr`: CI builds and pushes the container image to Azure Container Registry on every merge to `main`
- `crafted-specially-k8s-deployment`: Kubernetes manifests that describe how the CraftedSpecially API runs in the cluster (Deployment + Service)
- `crafted-specially-argo-app`: Argo CD Application resource that syncs the workload manifests to the cluster via GitOps

### Modified Capabilities

- `gitops-sync-policy`: The existing sync policy spec may need updating to reference the new application path; depends on whether the spec captures per-app path conventions

## Impact

- `.github/workflows/ci.yml`: add ACR login step and update `docker/build-push-action` target registry
- `infra/k8s/crafted-specially/`: new directory with `deployment.yaml` and `service.yaml`
- `infra/k8s/argocd/apps/crafted-specially.yaml`: new Argo CD Application manifest picked up by the root app
- No Bicep changes required; ACR + AKS + RBAC are already provisioned
