## Context

The cluster already has two infrastructure tools (cert-manager and envoy-gateway) managed via ArgoCD using a multi-source Application pattern:
1. A Helm chart source pointing at a remote chart registry.
2. A values file reference source pointing at the Git repo (`ref: values`).
3. An optional raw-manifest source for additional CRDs or config objects.

Chaos Mesh (`chaos-mesh/chaos-mesh` from `https://charts.chaos-mesh.org`) follows the same Helm-based deployment model. The chart installs its own CRDs and creates a controller in a dedicated namespace (`chaos-mesh`). An existing Azure Chaos Studio Bicep module handles node-level faults; Chaos Mesh is additive and operates at the pod/network level.

## Goals / Non-Goals

**Goals:**
- Install Chaos Mesh on the cluster using the existing GitOps pattern (ArgoCD + Helm multi-source).
- Pin to a specific chart version for reproducibility.
- Run Chaos Mesh controller pods on the workload node pool, consistent with other infrastructure components.
- Let the chart manage CRD installation (same approach as cert-manager).

**Non-Goals:**
- Defining specific `ChaosExperiment` or `PodChaos` resources — those belong to per-experiment manifests created separately.
- Integrating with Azure Chaos Studio — they are complementary, not merged.
- Dashboard setup or RBAC policy beyond the chart defaults.

## Decisions

**1. Use the official `chaos-mesh/chaos-mesh` Helm chart**

The official chart from `https://charts.chaos-mesh.org` is the canonical installation path, mirrors how cert-manager uses `https://charts.jetstack.io`. Alternative: raw manifest install (`kubectl apply`) — rejected because it bypasses Helm lifecycle management and drift detection.

**2. Same sync wave (`-1`) as cert-manager and envoy-gateway**

Chaos Mesh installs CRDs at startup; workload apps that reference `PodChaos` etc. must find those CRDs present. Running in wave `-1` alongside cert-manager (which also installs CRDs) ensures ordering before application workloads in wave `0`. Alternative: wave `0` — rejected because CRDs may not be ready when apps sync.

**3. Chart-managed CRDs (`chaosDaemon.runtime: containerd`, CRDs bundled)**

The chart's built-in CRD management (`controllerManager.enableFilterNamespace: false`) is sufficient for this project's scale. A separate CRD Application (like `gateway-api-crds.yaml`) was considered but adds unnecessary indirection when the chart already handles it.

**4. Namespace: `chaos-mesh`**

Follows Chaos Mesh upstream convention and mirrors the pattern of dedicated namespaces for each infrastructure component (`cert-manager`, `envoy-gateway-system`).

## Risks / Trade-offs

- **CRD version conflicts** → Chaos Mesh CRDs are cluster-scoped; upgrading the chart may require a CRD migration step. Mitigation: pin chart version; review CRD changelog before upgrades.
- **`containerd` socket assumption** → The values assume `containerd` as the runtime (standard for AKS). If the cluster runtime changes, `chaosDaemon.runtime` must be updated. Mitigation: documented in `values.yaml` comment.
- **Privileged daemonset** → `chaos-daemon` runs privileged to inject faults. This is expected and necessary; ensure cluster security policies (e.g., Pod Security Standards) permit it in the `chaos-mesh` namespace.
