## ADDED Requirements

### Requirement: Argo CD Application resource manages the CraftedSpecially workload
An Argo CD `Application` manifest SHALL exist at `infra/k8s/argocd/apps/crafted-specially.yaml`. It SHALL point to `infra/k8s/crafted-specially/` in the repository and be picked up automatically by the root app.

#### Scenario: Root app discovers the new Application
- **WHEN** `crafted-specially.yaml` is merged to the tracked branch
- **THEN** the root Argo CD app detects the new Application manifest and creates it in the `argocd` namespace

#### Scenario: Application syncs workload manifests
- **WHEN** the CraftedSpecially Application is created or its source path changes
- **THEN** Argo CD applies all manifests under `infra/k8s/crafted-specially/` to the `crafted-specially` namespace

### Requirement: CraftedSpecially Application follows the automated sync policy
The Application SHALL have `syncPolicy.automated` with `selfHeal: true` and `prune: true`, consistent with the `gitops-sync-policy` spec.

#### Scenario: Manifest update triggers automatic sync
- **WHEN** a manifest under `infra/k8s/crafted-specially/` is merged to the target branch
- **THEN** Argo CD automatically applies the change without manual intervention

#### Scenario: Out-of-band change is reverted
- **WHEN** a resource managed by the CraftedSpecially Application is manually edited in the cluster
- **THEN** Argo CD reverts it to the git-defined state within the self-heal interval

### Requirement: Application targets the `crafted-specially` namespace with namespace creation enabled
The Application destination SHALL specify `namespace: crafted-specially` and include `CreateNamespace=true` in `syncOptions`.

#### Scenario: First-time deployment creates namespace
- **WHEN** the Application syncs for the first time on a fresh cluster
- **THEN** the `crafted-specially` namespace is created before workload resources are applied
