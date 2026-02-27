## ADDED Requirements

### Requirement: Experiment deploys via Bicep
The system SHALL provide a Bicep template that creates an Azure Chaos Studio experiment, a Chaos capability resource, and a managed identity with the required RBAC role assignment, all scoped to a configurable resource group.

#### Scenario: Successful Bicep deployment
- **WHEN** an operator runs `az deployment group create` with `infra/chaos/main.bicep` and valid parameters
- **THEN** the Azure subscription SHALL contain a Chaos Studio experiment resource, a Chaos capability for AKS node pool shutdown, and a managed identity with `Azure Kubernetes Service Cluster Admin Role` on the target AKS cluster

#### Scenario: Idempotent deployment
- **WHEN** the Bicep deployment is run a second time with the same parameters
- **THEN** no duplicate resources SHALL be created and existing resources SHALL be updated in-place

---

### Requirement: Dynamic target selection via resource tags
The experiment SHALL resolve target AKS node pool resource IDs at start time using Azure Resource Graph, filtering on tags `chaos-target=true` and `environment=<env>`, so that hard-coded resource IDs are never required.

#### Scenario: Tagged node pools are targeted
- **WHEN** one or more AKS user node pools carry the tags `chaos-target=true` and `environment=staging`
- **THEN** the experiment SHALL include exactly those node pools as targets and no others

#### Scenario: Missing tags result in error
- **WHEN** no node pools in the subscription carry the required tags
- **THEN** the runner SHALL exit with a non-zero status and a human-readable error message before starting the experiment

---

### Requirement: Zone-scoped node shutdown fault
The experiment SHALL trigger an `AKSNodePoolShutdown` fault scoped to a single configurable availability zone (1, 2, or 3), ensuring only nodes in the specified zone are drained.

#### Scenario: Single-zone fault
- **WHEN** the experiment runs targeting zone 2
- **THEN** nodes in availability zone 2 SHALL be cordoned and drained; nodes in zones 1 and 3 SHALL remain running

#### Scenario: Configurable zone parameter
- **WHEN** the experiment is deployed with `targetZone=3`
- **THEN** the fault step SHALL reference zone 3 and no other zone

---

### Requirement: Configurable experiment duration
The experiment duration SHALL be a configurable parameter (default: 10 minutes) to accommodate different test windows.

#### Scenario: Default duration
- **WHEN** the experiment is deployed without specifying duration
- **THEN** the fault step SHALL run for 10 minutes before the nodes are restored

#### Scenario: Custom duration
- **WHEN** the experiment is deployed with `faultDurationMinutes=5`
- **THEN** the fault step SHALL run for exactly 5 minutes
