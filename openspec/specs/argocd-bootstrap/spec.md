## ADDED Requirements

### Requirement: ArgoCD is installed in the cluster
The system SHALL have ArgoCD installed in the `argocd` namespace via a versioned Helm chart with a values file committed to the repository at `infra/k8s/argocd/values.yaml`. The installation SHALL be reproducible from a single bootstrap script.

#### Scenario: Fresh cluster bootstrap
- **WHEN** an operator runs the bootstrap script against an empty cluster
- **THEN** ArgoCD is installed in the `argocd` namespace and all ArgoCD pods reach `Running` state

#### Scenario: Idempotent re-run
- **WHEN** the bootstrap script is run a second time on a cluster that already has ArgoCD installed
- **THEN** the command completes without error and the existing ArgoCD installation is unchanged

### Requirement: ArgoCD has read access to the git repository
The system SHALL configure ArgoCD with a read-only SSH deploy key stored as a Kubernetes Secret so it can pull manifests from the repository. The deploy key SHALL NOT have write access to the repository.

#### Scenario: Repository is reachable
- **WHEN** ArgoCD is bootstrapped with a valid deploy key
- **THEN** ArgoCD can list and read the `infra/k8s/` directory from the configured repository URL

#### Scenario: Invalid deploy key is rejected
- **WHEN** an invalid or expired deploy key is provided
- **THEN** ArgoCD reports a `ComparisonError` on affected Applications and does NOT sync

### Requirement: Bootstrap is a one-time manual step
The cluster SHALL reach a fully GitOps-managed state after a single manual bootstrap execution. All subsequent changes to cluster state SHALL be driven by git commits, not manual commands.

#### Scenario: Post-bootstrap state
- **WHEN** the bootstrap script completes successfully
- **THEN** all infrastructure Applications appear in ArgoCD and no further `kubectl apply` or `helm upgrade` commands are required to manage existing resources
