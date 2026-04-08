## Context

CraftedSpecially runs on AKS and uses Kubernetes for its API gateway layer (Envoy Gateway, cert-manager, HTTPRoutes). All resources are currently provisioned imperatively: an operator runs `helm upgrade --install` and `kubectl apply` commands from a README runbook. There is no automated reconciliation, no audit trail of cluster changes, and no protection against configuration drift.

The existing `infra/k8s/` directory already organises resources cleanly into component subdirectories with Helm values files and raw manifests — this is a good foundation for GitOps without restructuring.

## Goals / Non-Goals

**Goals:**
- Install ArgoCD as the cluster's GitOps controller
- Wrap every existing Helm release and raw manifest set in an ArgoCD `Application`
- Use the App-of-Apps pattern so the entire cluster can be bootstrapped from a single `kubectl apply`
- Enable automated sync with self-heal and prune so the cluster continuously reconciles to git
- Keep `infra/k8s/` structure intact; ArgoCD reads it as-is

**Non-Goals:**
- Application workload deployment (CraftedSpecially.Api container) is out of scope for this change
- Migrating to a different CD tool or evaluating Flux
- Changing Helm chart versions or manifest content during migration
- Multi-cluster or multi-tenant ArgoCD setup

## Decisions

### Decision 1: App-of-Apps vs ApplicationSet

**Choice**: App-of-Apps (a root `Application` whose source is a directory of child `Application` manifests).

**Rationale**: The cluster has a small, fixed set of components (cert-manager, Envoy Gateway, Gateway API CRDs, HTTPRoutes). ApplicationSet's generator patterns add complexity that isn't warranted here. App-of-Apps is simpler, fully transparent, and easier to reason about for a demo project.

**Alternative considered**: ApplicationSet with a directory generator — rejected because it auto-discovers apps dynamically, making the dependency/sync-wave ordering less explicit.

---

### Decision 2: ArgoCD installation method — Helm vs plain manifest

**Choice**: Install ArgoCD via Helm chart (`argo/argo-cd`) with a values file at `infra/k8s/argocd/values.yaml`.

**Rationale**: Helm gives version pinning, structured configuration overrides, and upgrade consistency. The rest of the stack (cert-manager, Envoy Gateway) already uses Helm, so the pattern is familiar.

**Alternative considered**: Plain `install.yaml` from the ArgoCD GitHub releases — simpler initially but harder to customise and upgrade.

---

### Decision 3: Sync policy — automated vs manual

**Choice**: Automated sync with `selfHeal: true` and `prune: true` for infrastructure components.

**Rationale**: GitOps only provides drift-prevention value when reconciliation is automatic. Manual sync would still require a human trigger and defeats the purpose of this migration.

**Risk acknowledged**: `prune: true` will delete cluster resources removed from git. This is intentional and desirable, but operators must be careful not to delete manifests accidentally.

---

### Decision 4: Repository access — deploy key

**Choice**: ArgoCD accesses the repository via a read-only SSH deploy key stored as a Kubernetes Secret.

**Rationale**: Minimal permission footprint. The deploy key grants read-only access to a single repository, which is all ArgoCD needs. GitHub App integration is more powerful but overkill for a single-repo setup.

---

### Decision 5: Sync waves for ordering

**Choice**: Use ArgoCD sync waves (`argocd.argoproj.io/sync-wave` annotation) to enforce deploy order:

| Wave | Component |
|------|-----------|
| -2 | Gateway API CRDs |
| -1 | cert-manager, Envoy Gateway |
|  0 | GatewayClass, Gateway, ClusterIssuers |
|  1 | Certificate, HTTPRoutes |

**Rationale**: Several components have hard dependencies (CRDs must exist before controllers; controllers must be ready before their custom resources). Sync waves encode this ordering declaratively.

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| ArgoCD bootstrap is itself manual (chicken-and-egg) | Document a clear one-time bootstrap script; after that all changes are GitOps-managed |
| `prune: true` deletes resources removed from git | Code review on PRs touching `infra/k8s/`; ArgoCD UI shows what will be pruned before sync |
| ArgoCD adds cluster-admin-level access to the repo | Use read-only deploy key; ArgoCD RBAC scoped to `infra/k8s/` namespace resources |
| Helm chart drift between local values and ArgoCD-rendered output | ArgoCD renders Helm server-side so the rendered manifests are visible in the UI for inspection |

## Migration Plan

1. **Prepare ArgoCD install manifests** — add `infra/k8s/argocd/values.yaml` and a bootstrap script
2. **One-time bootstrap** — operator runs the bootstrap script once to install ArgoCD and apply the root App
3. **ArgoCD takes ownership** — root App syncs child Apps; child Apps sync existing components
4. **Validate** — confirm all Applications reach `Healthy/Synced` state; verify existing gateway traffic is unaffected
5. **Retire manual runbook** — update README to reflect ArgoCD-driven workflow

**Rollback**: Delete ArgoCD namespace and re-apply resources manually from `infra/k8s/`. No application manifests change, so rollback restores the pre-ArgoCD state cleanly.

## Open Questions

- What GitHub/AzureDevOps repository URL should ArgoCD use? (public HTTPS vs SSH)
- Should the ArgoCD UI be exposed via an HTTPRoute on the existing gateway, or kept cluster-internal?
- Is a notification/alerting integration (Slack, Teams) needed for sync failures?
