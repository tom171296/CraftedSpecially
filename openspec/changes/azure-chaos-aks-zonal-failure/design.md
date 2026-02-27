## Context

CraftedSpecially runs on AKS across multiple availability zones. To verify that the cluster survives a zone loss, we will use **Azure Chaos Studio** — Microsoft's managed fault-injection service — to simulate the failure of all nodes in a single zone. The experiment targets node pools dynamically via Azure resource tags, so it remains valid across environment refreshes and resource renames.

Current state: no chaos experiments exist. Infrastructure is defined with Bicep under `infra/`.

## Goals / Non-Goals

**Goals:**

- Deploy an Azure Chaos Studio experiment (Bicep) that faults one AKS availability zone.
- Target node pools via tags (`chaos-target: true`, `environment: <env>`) so hard-coded resource IDs are never required.
- Provide a runner script (Bash / Azure CLI) that starts the experiment, polls status, and verifies workload health.
- Document pre-flight checks and a pass/fail definition.

**Non-Goals:**

- Automated chaos in production without human approval.
- Application-layer faults via Chaos Mesh (HTTP latency injection, pod kills) — deferred to a future change, not excluded.
- Changes to AKS cluster configuration or pod disruption budgets (those are pre-conditions, not deliverables).
- Multi-zone simultaneous failure.

## Decisions

### Decision 1 — Use Azure Chaos Studio (managed) over Chaos Mesh (in-cluster)

**Chosen:** Azure Chaos Studio node-pool shutdown fault.

**Alternatives considered:**

| Option | Decision |
|---|---|
| Chaos Mesh (in-cluster CRD) | **Deferred** — targets application-layer faults (latency, pod kills) which complement infrastructure-layer faults. Intended for a follow-up change. Choosing Chaos Studio now does not block adding Chaos Mesh later; they address different fault domains and coexist. |
| Manual `kubectl drain` + cordon | Rejected — not reproducible, not version-controlled, can't be triggered from CI. |
| Azure Chaos Studio VM Scale Set shutdown | Rejected — operates at VMSS level without guaranteed zone-scoping. The AKS-native fault (`Microsoft.ContainerService/managedClusters`) provides explicit zone targeting. |

**Rationale:** Azure Chaos Studio is a first-party managed service with native ARM/Bicep support, built-in RBAC, and an AKS zonal fault type (`AKSNodePoolShutdown`). No cluster-side components needed. Chaos Mesh is intentionally left for a separate change to cover application-layer fault injection.

---

### Decision 2 — KQL `Query` selector for dynamic target resolution at runtime

**Chosen:** The Chaos Studio experiment uses a `Query` selector type. Azure resolves targets at runtime via a KQL query over Azure Resource Graph — no resource IDs in the template at all.

```
Resources
| where type == 'microsoft.compute/virtualmachinescalesets'
| where tags['chaos-target'] == 'true' and tags['environment'] == '<env>'
```

**Why not a `List` selector with resource IDs passed as parameters:**  
A `List` selector requires resolving IDs before deploying the experiment. That means either baking stale IDs into the template or re-deploying the experiment from the runner script on every run. Both break the "deploy once, run many times" model. The `Query` selector removes the ID dependency entirely — the experiment definition is stable; only the tags on the VMSSes need to be correct.

The runner script runs the same KQL query independently to discover VMSSes for capability registration (capabilities must be pre-enabled on targets before an experiment can use them).

---

### Decision 3 — One experiment per environment, zone chosen at runtime

The Bicep template deploys a single Chaos Studio experiment resource. The zone number (1, 2, or 3) is passed as a parameter. This allows the same template to test any zone without duplication.

---

### Decision 4 — Chaos deployed with main infrastructure, not standalone

The chaos module is called from `runtime_infrastructure.bicep` alongside AKS, App Config, and observability. A standalone `az deployment group create` for the chaos experiment was rejected — it creates a separate deployment lifecycle and makes it easy to miss in environment refreshes. Deploying with the main infra ensures the experiment always exists when the cluster does.

```
infra/
  chaos/
    main.bicep           # Chaos module entry point (called by runtime_infrastructure.bicep)
    run-experiment.sh    # Runner script
    README.md
    modules/
      chaos-experiment.bicep   # Experiment resource with KQL Query selector
      chaos-capability.bicep   # VMSS chaos target + Shutdown-2.0 capability
infra/modules/runtime_infrastructure/
  runtime_infrastructure.bicep  # Calls ../../chaos/main.bicep
```

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| Experiment accidentally targets production | Parameter validation in runner script; separate `environment` tag value per env; manual approval gate in CI |
| Node pool tag missing → empty target set | Runner validates non-empty target list before starting experiment; fails fast with clear error |
| AKS node recovery takes longer than experiment duration | Set experiment duration to 10 minutes (configurable). Add post-experiment health check with retry window. |
| Chaos Studio managed identity lacks permissions | Bicep grants `Azure Kubernetes Service Cluster Admin Role` scoped to the AKS resource at deploy time. Document in runbook. |
| Zone shutdown leaves pods in `Terminating` state | Expected behavior; runner validates that pods eventually reschedule (health check loop with timeout). |

## Migration Plan

1. Deploy `infra/chaos/main.bicep` to target subscription (`az deployment group create`).
2. Tag the relevant AKS node pools: `chaos-target=true`, `environment=<env>`.
3. Run `infra/chaos/run-experiment.sh --env <env> --zone 1` to verify end-to-end.
4. (Optional) Wire runner script into a pipeline stage with manual approval.

Rollback: delete the Chaos Studio experiment resource. No changes are made to AKS or application code.

## Open Questions

- Should the experiment also cover system node pools, or only user node pools? (Recommend: user pools only for initial scope.)
- Target zone selection: random or always zone 1 in lower environments? Runner can accept `--zone random` as a follow-up.
