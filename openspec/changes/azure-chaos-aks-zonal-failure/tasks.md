## 1. Bicep Infrastructure — Chaos Capability & Experiment

- [x] 1.1 Create `infra/chaos/` directory structure with `main.bicep`, `main.bicepparam`, and `modules/` subdirectory
- [x] 1.2 Write `modules/chaos-capability.bicep` — defines the Chaos Studio capability resource for `AKSNodePoolShutdown` targeting the managed cluster
- [x] 1.3 Write `modules/chaos-experiment.bicep` — defines the experiment with a parameterized zone and duration; accepts `targetResourceIds` as an array parameter
- [x] 1.4 Write `infra/chaos/main.bicep` — wires capability + experiment modules, creates managed identity, assigns `Azure Kubernetes Service Cluster Admin Role` scoped to the AKS resource
- [x] 1.5 Write `infra/chaos/main.bicepparam` with environment-specific defaults (experiment name, resource group, AKS cluster resource ID)

## 2. Dynamic Tag-Based Targeting

- [x] 2.1 Add Azure Resource Graph query logic to `run-experiment.sh` that fetches node pool resource IDs filtered by `chaos-target=true` and `environment=<env>` tags
- [x] 2.2 Validate that the query returns at least one resource ID; exit with descriptive error if empty
- [x] 2.3 Pass resolved resource IDs as the `targetResourceIds` parameter when invoking the Bicep deployment (or as a separate `az chaos experiment` update call if experiment is pre-deployed)

## 3. Runner Script — Pre-flight Checks

- [x] 3.1 Create `infra/chaos/run-experiment.sh` with argument parsing for `--env`, `--zone`, `--timeout`, `--force`, and `--namespace` flags
- [x] 3.2 Implement pre-flight: verify `az` CLI is logged in and the correct subscription is active
- [x] 3.3 Implement pre-flight: run the Resource Graph query and assert non-empty target list
- [x] 3.4 Implement pre-flight: check all AKS nodes are `Ready`; block on failure unless `--force` is passed

## 4. Runner Script — Experiment Execution & Polling

- [x] 4.1 Add experiment start step: call `az chaos experiment start` with the resolved experiment resource ID
- [x] 4.2 Implement polling loop: query run status every 30 seconds, print progress, exit loop on `Succeeded`, `Failed`, or `Cancelled`
- [x] 4.3 Enforce configurable timeout (default 20 minutes); print warning and exit non-zero if timeout elapses
- [x] 4.4 Print experiment run ID and Azure Portal deep-link at start for live monitoring

## 5. Runner Script — Post-Experiment Health Check

- [x] 5.1 Implement post-experiment check: poll pod status in target namespace(s) every 15 seconds
- [x] 5.2 Declare `PASS` (exit 0) when all pods reach `Running`; declare `FAIL` (exit 1) if recovery window (default 5 minutes) elapses with non-Running pods
- [x] 5.3 Print list of offending pods and their current status on failure

## 6. Runbook Documentation

- [x] 6.1 Create `infra/chaos/README.md` documenting: prerequisites (Azure CLI, permissions, required tags), deployment steps, how to run the experiment, and pass/fail criteria
- [x] 6.2 Document rollback procedure: how to stop an in-progress experiment and delete the Chaos Studio resource if needed
