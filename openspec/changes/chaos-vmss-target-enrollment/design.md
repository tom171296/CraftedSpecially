## Context

The previous change (`azure-chaos-aks-zonal-failure`) deployed the Chaos Studio experiment with a KQL `Query` selector that discovers VMSS targets at runtime. Two prerequisites were left as manual steps in the README:

1. **Tags** — VMSSes in the AKS node resource group (`MC_*`) must carry `chaos-target=true` and `environment=<env>`. These tags are never set by the infrastructure stack.
2. **Chaos target enrollment** — Each VMSS must have a `Microsoft.Chaos/targets/Microsoft-VirtualMachineScaleSet` child resource and a `Shutdown-2.0` capability registered before Chaos Studio can use it. The module `chaos-capability.bicep` exists but is never called from `chaos.bicep`.

The run-experiment.sh script registers capabilities at runtime, but this creates a dependency on the human operator running the script before the experiment works. Both steps belong in the Bicep deployment stack alongside the experiment.

AKS VMSSes live in an auto-generated node resource group (`MC_<rg>_<cluster>_<region>`). Their names follow the pattern `aks-<pool>-<random>-vmss` and are stable after cluster creation — they do not change unless the node pool is recreated.

## Goals / Non-Goals

**Goals:**

- Apply `chaos-target=true` and `environment=<env>` tags to the specified VMSSes via Bicep.
- Register `Microsoft-VirtualMachineScaleSet` target and `Shutdown-2.0` capability on each VMSS via Bicep, wiring `chaos-capability.bicep` into the deployment.
- Keep the `chaos.bicep` module as the single orchestration point; callers only need to provide the VMSS names.

**Non-Goals:**

- Automatically discovering VMSS names at deploy time (e.g., via ARM template functions or deployment scripts) — names are passed as a parameter.
- Modifying the KQL query or experiment selector logic.
- Tagging system node pool VMSSes; only user node pools are targeted.

## Decisions

### Decision 1 — Pass VMSS names as a parameter array, not autodiscovered

**Chosen:** `chaos.bicep` accepts a `vmssNames` string array. Each name maps to a VMSS in `nodeResourceGroupName`. Tags and capabilities are applied via a Bicep `for` loop over this array.

**Alternatives considered:**

| Option | Decision |
|---|---|
| Bicep `deploymentScript` (ACI) to list VMSSes at deploy time | Rejected — requires a container instance, a storage account, and a user-assigned identity with elevated permissions; heavyweight for a one-time lookup that is stable post-cluster-creation. |
| Derive VMSS names from AKS `agentPools` API | Rejected — the agent pool sub-resource does not expose the backing VMSS name in a stable, Bicep-readable property without a deployment script. |
| Keep manual tagging via README | Rejected — manual steps are error-prone and invisible to the deployment pipeline; the root cause of the current bug. |

**Rationale:** VMSS names in the `MC_*` resource group are stable after AKS cluster creation. Accepting them as an explicit parameter keeps the Bicep simple, avoids side-effecting dependencies, and surfaces the names at the call site where the operator controls them.

---

### Decision 2 — Apply tags and capabilities in the same loop, scoped to the node resource group

`chaos.bicep` already references `nodeResourceGroup` as an existing resource (added in the RBAC fix). The tag + capability modules are deployed as cross-resource-group modules using `scope: resourceGroup(nodeResourceGroupName)` on each module call in the loop.

The `chaos-capability.bicep` module (already written) needs no changes. A new `chaos-vmss-tags.bicep` module handles tag application to a single VMSS.

---

### Decision 3 — Tag application uses `resource ... existing` + `tags` merge, not `az tag update`

Bicep's `resource` declaration with `tags:` replaces the full tag set. To avoid overwriting AKS-managed tags, the new module passes through the existing tags and adds the chaos tags. Since AKS sets its own tags at node pool level, the Bicep module reads the existing VMSS `tags` property and merges via `union()`.

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| Deploying with wrong VMSS name silently no-ops | Bicep `existing` reference fails at deploy time with a 404 if the name is wrong — error surfaces immediately. |
| AKS recreates a node pool, generating a new VMSS name | The old capability registration becomes an orphan. Re-deploying the stack with the updated name is the remediation path; documented in the runbook. |
| Tag union with AKS-managed tags causes drift | The module merges tags additively using `union()`; it never removes existing tags. AKS reconciliation may remove chaos tags over time on some Kubernetes versions — mitigation is to re-run the deployment. |
| Capability registration runs before managed identity Reader role is active | ARM role propagation can take a few minutes. The chaos experiment itself is the last resource deployed; adding a `dependsOn` on the identity role assignments in `chaos.bicep` ensures sequencing. |

## Migration Plan

1. Identify VMSS names in the node resource group:
   ```bash
   NODE_RG=$(az aks show -g CraftedSpecially -n CraftedSpecially-aks --query nodeResourceGroup -o tsv)
   az vmss list -g "$NODE_RG" --query "[].name" -o tsv
   ```
2. Pass the names as `vmssNames` when deploying:
   ```bash
   az deployment group create \
     --resource-group CraftedSpecially \
     --template-file infra/modules/management_governance/chaos/chaos.bicep \
     --parameters environment=staging nodeResourceGroupName="$NODE_RG" vmssNames='["aks-user-12345678-vmss"]'
   ```
3. Verify tags and capabilities in the portal or via CLI before running the experiment.
4. Run `infra/chaos/run-experiment.sh --env staging --zone 1` — pre-flight should now find targets.

Rollback: remove the `chaos-target` tag and delete the `Microsoft.Chaos/targets` child resource from each VMSS. The experiment resource itself is unaffected.
