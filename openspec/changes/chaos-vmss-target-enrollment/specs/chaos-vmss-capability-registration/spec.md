## ADDED Requirements

### Requirement: chaos.bicep deploys Chaos capability for each VMSS
`chaos.bicep` SHALL deploy `chaos-capability.bicep` for every VMSS name in `vmssNames`, scoped to the node resource group, so that each VMSS is enrolled as a Chaos Studio target before the experiment resource is created.

#### Scenario: Capability registered on target VMSS
- **WHEN** `chaos.bicep` is deployed with a non-empty `vmssNames` array
- **THEN** each named VMSS SHALL have a `Microsoft.Chaos/targets/Microsoft-VirtualMachineScaleSet` child resource and a `Shutdown-2.0` capability registered in Azure

#### Scenario: Capability registration precedes experiment deployment
- **WHEN** the Bicep deployment executes
- **THEN** all capability module deployments SHALL complete before the `chaos-experiment.bicep` module is deployed, ensuring the KQL selector can resolve enrolled targets on first run

#### Scenario: Idempotent capability registration
- **WHEN** `chaos.bicep` is deployed a second time with the same `vmssNames`
- **THEN** no duplicate capability resources SHALL be created and the deployment SHALL succeed without errors

---

### Requirement: Enrolled VMSSes are discoverable by the KQL selector
After capability registration, the Chaos Studio experiment's KQL `Query` selector SHALL return the enrolled VMSSes as valid targets when the experiment is started.

#### Scenario: KQL selector finds tagged and enrolled VMSSes
- **WHEN** a VMSS has both `chaos-target=true` / `environment=<env>` tags AND a registered `Shutdown-2.0` capability
- **THEN** the Chaos Studio experiment's target resolution SHALL include that VMSS and the experiment SHALL start without a "no targets found" error

#### Scenario: Untagged VMSS is not selected
- **WHEN** a VMSS has a registered capability but no `chaos-target=true` tag
- **THEN** the KQL selector SHALL NOT include it in the target set
