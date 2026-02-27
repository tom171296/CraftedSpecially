## ADDED Requirements

### Requirement: ArgoCD Application for Chaos Mesh
The cluster configuration SHALL include an ArgoCD `Application` manifest that installs Chaos Mesh via the official Helm chart using the same multi-source pattern as cert-manager and envoy-gateway. The Application MUST be placed at `infra/k8s/argocd/apps/chaos-mesh.yaml`, target namespace `chaos-mesh`, and run in sync wave `-1`.

#### Scenario: Chaos Mesh Application manifest exists
- **WHEN** ArgoCD syncs the cluster
- **THEN** the `chaos-mesh` Application is created in the `argocd` namespace and targets namespace `chaos-mesh`

#### Scenario: Correct Helm chart source
- **WHEN** the Application is inspected
- **THEN** one source SHALL point to the `chaos-mesh/chaos-mesh` chart at `https://charts.chaos-mesh.org` with a pinned `targetRevision`

#### Scenario: Values file sourced from Git
- **WHEN** the Application is inspected
- **THEN** one source SHALL reference the Git repo with `ref: values` and the Helm release SHALL include `$values/infra/k8s/chaos-mesh/values.yaml` in its `valueFiles`

#### Scenario: Namespace auto-creation
- **WHEN** ArgoCD syncs the Application for the first time
- **THEN** the `chaos-mesh` namespace SHALL be created automatically via the `CreateNamespace=true` sync option

### Requirement: Helm values file for Chaos Mesh
A Helm values file SHALL exist at `infra/k8s/chaos-mesh/values.yaml` that configures Chaos Mesh to run on the workload node pool and sets the container runtime to `containerd`.

#### Scenario: Node selector targets workload pool
- **WHEN** Chaos Mesh controller pods are scheduled
- **THEN** they SHALL land on nodes with label `agentpool: workloadpool`

#### Scenario: Container runtime is containerd
- **WHEN** the chaos-daemon is configured
- **THEN** `chaosDaemon.runtime` SHALL be set to `containerd` and `chaosDaemon.socketPath` SHALL be set to `/run/containerd/containerd.sock`

### Requirement: Automated sync with self-heal
The ArgoCD Application SHALL have automated sync enabled with `selfHeal: true` and `prune: true` so that cluster drift is corrected automatically.

#### Scenario: Drift is corrected
- **WHEN** a Chaos Mesh resource is manually deleted from the cluster
- **THEN** ArgoCD SHALL recreate it on the next sync cycle
