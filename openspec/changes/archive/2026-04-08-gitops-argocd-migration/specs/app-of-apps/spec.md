## ADDED Requirements

### Requirement: Root Application manages all child Applications
The system SHALL have a root ArgoCD `Application` (the "App of Apps") whose source is `infra/k8s/argocd/apps/` in the repository. This directory SHALL contain one child `Application` manifest per infrastructure component. The root Application SHALL be the only resource applied manually during bootstrap.

#### Scenario: Root App syncs child Applications
- **WHEN** the root Application is synced
- **THEN** ArgoCD creates all child Application resources defined in `infra/k8s/argocd/apps/`

#### Scenario: New component added to apps directory
- **WHEN** a new `Application` manifest is committed to `infra/k8s/argocd/apps/`
- **THEN** the root Application detects the new file and creates the child Application on next sync without manual intervention

### Requirement: Child Applications cover all existing components
The system SHALL have a dedicated ArgoCD `Application` for each of the following components:
- Gateway API CRDs (`infra/k8s/install-gateway-api-crds.sh` resources)
- cert-manager (Helm release + ClusterIssuers + Certificate)
- Envoy Gateway (Helm release + GatewayClass + Gateway)
- HTTPRoutes (`infra/k8s/routes/`)

#### Scenario: All components are represented
- **WHEN** ArgoCD is fully bootstrapped
- **THEN** the ArgoCD UI shows Applications for `gateway-api-crds`, `cert-manager`, `envoy-gateway`, and `httproutes`

#### Scenario: Component manifest updated in git
- **WHEN** a manifest file in `infra/k8s/` is updated via a git commit
- **THEN** the corresponding ArgoCD Application detects the diff and syncs the change to the cluster

### Requirement: Deploy order is enforced via sync waves
The system SHALL annotate child Application manifests with `argocd.argoproj.io/sync-wave` to enforce the following order: CRDs first, then controllers (cert-manager, Envoy Gateway), then custom resources (GatewayClass, Gateway, ClusterIssuers), then dependent resources (Certificate, HTTPRoutes).

#### Scenario: CRDs applied before controllers
- **WHEN** a full sync is triggered from a clean cluster
- **THEN** Gateway API CRDs are fully established before cert-manager or Envoy Gateway pods start

#### Scenario: Sync wave violation is prevented
- **WHEN** a wave-N Application is not yet `Healthy`
- **THEN** ArgoCD does NOT proceed to sync wave-N+1 Applications
