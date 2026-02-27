## Why

AKS workloads running across availability zones must tolerate the loss of a zone without downtime. Running a controlled zonal failure experiment validates that pod disruption budgets, topology spread constraints, and node affinity rules are correctly configured — and surfaces gaps before a real outage does.

## What Changes

- Add an Azure Chaos Studio experiment definition (Bicep) that triggers an AKS node pool zonal failure.
- Implement dynamic resource targeting using Azure resource tags (`chaos-target: true`, `environment: <env>`) so the experiment always hits the right node pool regardless of resource name changes.
- Add an experiment runner script (Azure CLI / PowerShell) that starts the experiment, monitors status, and reports pass/fail.
- Document the runbook: pre-flight checks, how to trigger, what to watch, and how to verify the workload survived.

## Capabilities

### New Capabilities

- `chaos-aks-zonal-experiment`: Azure Chaos Studio experiment that faults a single AKS availability zone. Targets node pools dynamically via resource tags rather than hard-coded resource IDs. Includes a capability resource definition, experiment JSON, and Bicep deployment template.
- `chaos-experiment-runner`: CLI runbook (script + documentation) for executing the experiment, polling for completion, and validating workload health before and after the fault.

### Modified Capabilities

<!-- None — this is a net-new capability. -->

## Impact

- **Infrastructure**: New Bicep modules under `infra/chaos/`. No changes to existing AKS or app infrastructure.
- **Azure permissions**: The Chaos Studio managed identity requires `Azure Kubernetes Service Cluster Admin Role` or a custom role scoped to the node pool resource group.
- **CI/CD**: Optional — the runner script can be invoked from a pipeline stage gated behind a manual approval.
- **No application code changes** required; the experiment targets infrastructure only.
