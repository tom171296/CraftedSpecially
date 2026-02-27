## Why

The project already uses Azure Chaos Studio for node-level fault injection, but lacks application-level chaos testing (pod failures, network delays, CPU stress) inside the cluster. Chaos Mesh fills this gap by running as an in-cluster operator that injects faults directly into Kubernetes workloads, matching the existing GitOps pattern already established for cert-manager and envoy-gateway.

## What Changes

- Add a new `infra/k8s/chaos-mesh/` directory with a Helm values file and any required CRD/config manifests.
- Add a new ArgoCD `Application` manifest at `infra/k8s/argocd/apps/chaos-mesh.yaml` that installs Chaos Mesh via its official Helm chart using the same multi-source pattern as cert-manager and envoy-gateway.

## Capabilities

### New Capabilities

- `chaos-mesh-installation`: Declarative GitOps installation of Chaos Mesh on the cluster via an ArgoCD Application and Helm chart, providing the foundation for in-cluster chaos experiments.

### Modified Capabilities

## Impact

- **New files**: `infra/k8s/chaos-mesh/values.yaml`, `infra/k8s/argocd/apps/chaos-mesh.yaml`
- **No application code changes** — purely infrastructure additions.
- **Dependencies**: Chaos Mesh Helm chart (`chaos-mesh/chaos-mesh`) from `https://charts.chaos-mesh.org`; requires CRDs to be installed by the chart.
- **Sync order**: Chaos Mesh should install in the same sync wave as cert-manager and envoy-gateway (`sync-wave: "-1"`).
