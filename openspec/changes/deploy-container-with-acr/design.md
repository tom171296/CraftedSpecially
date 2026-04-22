## Context

CraftedSpecially is a .NET modular-monolith API running in AKS. The cluster is already provisioned (AKS + ACR + Argo CD root app). CI currently builds the image and pushes it to GHCR. The deployment leg of the pipeline is commented out and no Kubernetes manifests exist for the application workload.

The AKS Bicep module already assigns the `AcrPull` role to the kubelet managed identity against the ACR, so no infrastructure change is needed. Argo CD's root app watches `infra/k8s/argocd/apps/` and auto-syncs any Application resource placed there.

## Goals / Non-Goals

**Goals:**
- Push the built container image to ACR from CI on every merge to `main`
- Provide Kubernetes manifests (Deployment + Service) for the CraftedSpecially API
- Register the workload as an Argo CD Application so GitOps drives deployment

**Non-Goals:**
- Removing the existing GHCR push (kept for now to avoid disrupting any current consumers)
- Horizontal Pod Autoscaler or resource quota tuning (post-MVP)
- Ingress / HTTPRoute for the service (covered by existing `httproutes` Argo app)
- Secrets management for app config (separate concern, Azure App Config integration already tracked)

## Decisions

### 1. Push to ACR from CI using OIDC federated identity (no stored secrets)

The CI workflow already uses `permissions: id-token: write` for the sign/provenance job. We extend the same pattern to the build job: use `azure/login` with OIDC + a GitHub Actions federated credential on the workload identity, then `docker/login-action` with the ACR endpoint.

**Alternative considered:** Use ACR admin credentials stored as GitHub secrets.  
**Rejected:** Admin credentials are a long-lived secret that violates least-privilege; the OIDC path is already scaffolded for this repo.

### 2. Image tag strategy: `sha-<git-sha>` + `latest`

Tag with the full Git SHA for traceability and `latest` for the Argo CD Application's image reference during initial rollout. A future change can switch to image-updater or Kustomize overlays for proper SHA-pinned GitOps.

**Alternative considered:** Semantic versioning tags.  
**Deferred:** No release tagging process exists yet; SHA is reproducible and sufficient.

### 3. Argo CD Application with `targetRevision: HEAD` pointing at `infra/k8s/crafted-specially/`

This follows the exact same pattern as the existing `httproutes` Application. The root app at `infra/k8s/argocd/apps/` picks up any new Application manifest automatically.

### 4. Deployment namespace: `crafted-specially`

Isolate the workload in its own namespace to match the intent of the commented-out CI deployment step. Argo CD's `CreateNamespace: true` sync option handles namespace creation.

### 5. No Bicep changes required

The AKS module already creates the `AcrPull` role assignment for the kubelet identity. The ACR and AKS are in the same resource group, so the scope resolves correctly. Verified by inspecting `infra/modules/runtime_infrastructure/hosting/AKS.bicep`.

## Risks / Trade-offs

- **ACR OIDC federated credential must be created** — a GitHub Actions federation on the workload identity needs to be created (either manually or via Bicep in a follow-up). Without it, the `azure/login` step will fail. → Mitigation: document the one-time setup step; it does not block CI for PRs since the ACR push only runs on `main`.
- **`latest` tag breaks reproducible deploys** — using `latest` means Argo CD won't detect image changes (the manifest doesn't change). → Mitigation: accepted for initial rollout; tracked as a follow-up to integrate Argo CD Image Updater or SHA-pinned tags via Kustomize.
- **Namespace `crafted-specially` created by Argo CD** — if the namespace already exists with conflicting labels, sync may fail. → Mitigation: Argo CD's `ServerSideApply` and `CreateNamespace` options handle idempotent creation.

## Migration Plan

1. Create federated credential on the existing workload identity for the GitHub Actions OIDC issuer (one-time manual step or Bicep).
2. Merge CI workflow changes (ACR login + push).
3. Merge K8s manifests + Argo CD Application in the same PR (or stacked PRs per core rules).
4. Verify Argo CD syncs and pod reaches `Running` state.
5. Rollback: delete the Argo CD Application resource from git; Argo CD prune will remove workload resources.

## Open Questions

- Should the federated credential setup be automated via Bicep in this change, or handled as a prerequisite?
- What resource requests/limits should the Deployment have? (Default to conservative values for now.)
- Is the `crafted-specially` namespace already used for anything in the cluster?
