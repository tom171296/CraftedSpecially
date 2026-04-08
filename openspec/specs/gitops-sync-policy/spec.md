## ADDED Requirements

### Requirement: Applications sync automatically on git change
Each infrastructure Application SHALL have `syncPolicy.automated` enabled so that ArgoCD automatically triggers a sync when a difference between the git source and live cluster state is detected. No manual sync approval SHALL be required for infrastructure components.

#### Scenario: Manifest updated in git
- **WHEN** a manifest in `infra/k8s/` is merged to the main branch
- **THEN** ArgoCD detects the diff within the configured polling interval and applies the change to the cluster without human interaction

#### Scenario: No git change — no sync triggered
- **WHEN** the cluster state matches git and no commit has been made
- **THEN** ArgoCD reports all Applications as `Synced` and does NOT re-apply any resources

### Requirement: Self-heal restores cluster to git state
Each infrastructure Application SHALL have `syncPolicy.automated.selfHeal: true` so that out-of-band changes to cluster resources (e.g., manual `kubectl edit`) are automatically reverted to the git-defined state.

#### Scenario: Out-of-band change is reverted
- **WHEN** an operator manually edits a resource managed by an ArgoCD Application
- **THEN** ArgoCD detects the drift and reverts the resource to the state defined in git within the self-heal interval

#### Scenario: ArgoCD-managed secret is not overwritten
- **WHEN** ArgoCD self-heals a resource
- **THEN** resources annotated with `argocd.argoproj.io/managed: "false"` or excluded from sync are NOT modified

### Requirement: Pruning removes resources deleted from git
Each infrastructure Application SHALL have `syncPolicy.automated.prune: true` so that cluster resources deleted from the git repository are automatically removed from the cluster.

#### Scenario: Manifest deleted from git
- **WHEN** a Kubernetes manifest is deleted from `infra/k8s/` and merged to main
- **THEN** ArgoCD removes the corresponding cluster resource on the next sync

#### Scenario: Prune does not affect unmanaged resources
- **WHEN** a resource exists in the cluster namespace but is NOT tracked by any ArgoCD Application
- **THEN** ArgoCD does NOT delete that resource during sync

### Requirement: Sync failures surface as Application health degradation
The system SHALL report a sync failure as an `OutOfSync` or `Degraded` Application status visible in the ArgoCD UI and via the ArgoCD API. Failed syncs SHALL NOT silently pass.

#### Scenario: Invalid manifest committed
- **WHEN** a syntactically invalid Kubernetes manifest is committed to `infra/k8s/`
- **THEN** the corresponding ArgoCD Application transitions to `Degraded` and displays an error message describing the failure

#### Scenario: Healthy Application after successful sync
- **WHEN** all resources managed by an Application are live and match git
- **THEN** the Application reports `Healthy` and `Synced` status
