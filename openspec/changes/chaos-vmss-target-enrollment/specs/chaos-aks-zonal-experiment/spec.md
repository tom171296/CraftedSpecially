## MODIFIED Requirements

### Requirement: Experiment deploys via Bicep
The system SHALL provide a Bicep template that creates an Azure Chaos Studio experiment, registers Chaos capability resources on each target VMSS, applies required chaos tags to each target VMSS, and creates a managed identity with the required RBAC role assignments, all orchestrated from `chaos.bicep` scoped to the management resource group.

#### Scenario: Successful Bicep deployment
- **WHEN** an operator runs `az deployment group create` with `chaos.bicep` and valid parameters (including `nodeResourceGroupName` and `vmssNames`)
- **THEN** the Azure subscription SHALL contain a Chaos Studio experiment resource, chaos tags on each specified VMSS, a `Microsoft.Chaos/targets/Microsoft-VirtualMachineScaleSet` child resource and `Shutdown-2.0` capability on each VMSS, a managed identity with `Reader` role at subscription scope, and `Virtual Machine Contributor` role on the node resource group

#### Scenario: Idempotent deployment
- **WHEN** the Bicep deployment is run a second time with the same parameters
- **THEN** no duplicate resources SHALL be created and existing resources SHALL be updated in-place
