## Why

The Azure Chaos Studio experiment uses a KQL `Query` selector to discover targets at runtime, but two prerequisites are never automated: the required tags (`chaos-target=true`, `environment=<env>`) are not applied to AKS node pool VMSSes, and the VMSSes are never enrolled as Chaos Studio targets (i.e., `Microsoft.Chaos/targets` + `Shutdown-2.0` capability are not registered). Without these, the KQL selector always returns zero targets and the experiment cannot run.

## What Changes

- Add a Bicep module that reads the AKS cluster's node resource group and applies the `chaos-target=true` and `environment=<env>` tags to every user node pool VMSS.
- Deploy `chaos-capability.bicep` for each target VMSS so that `Microsoft-VirtualMachineScaleSet` target and `Shutdown-2.0` capability are registered — making them discoverable by the Chaos Studio KQL selector.
- Wire both modules into `chaos.bicep` so they deploy as part of the existing infrastructure stack; no manual tagging or REST calls required before running an experiment.

## Capabilities

### New Capabilities

- `chaos-vmss-tagging`: Bicep automation that tags AKS node pool VMSSes in the node resource group with `chaos-target=true` and `environment=<value>` so the KQL selector can discover them.
- `chaos-vmss-capability-registration`: Bicep automation that registers the `Microsoft-VirtualMachineScaleSet` Chaos target and `Shutdown-2.0` capability on each tagged VMSS, enrolling them in Chaos Studio.

### Modified Capabilities

- `chaos-aks-zonal-experiment`: The experiment deployment now depends on tagging and capability registration completing first; `chaos.bicep` must orchestrate all three steps in the correct order.

## Impact

- **Infrastructure**: Changes scoped to `infra/modules/management_governance/chaos/`. Adds tag writes and Chaos target registrations on VMSS resources in the `MC_*` node resource group.
- **Bicep scope**: Tag and capability resources live in the node resource group (a different resource group from the experiment), requiring cross-resource-group module calls.
- **RBAC**: The deploying principal needs `Tag Contributor` and `Contributor` on the node resource group in addition to existing permissions.
- **No application code changes** required.
