## ADDED Requirements

### Requirement: Bicep module applies chaos tags to VMSS
The system SHALL provide a `chaos-vmss-tags.bicep` module that sets `chaos-target=true` and `environment=<value>` tags on a specified VMSS resource without removing existing tags.

#### Scenario: Tags applied to untagged VMSS
- **WHEN** the module is deployed targeting a VMSS that has no existing chaos tags
- **THEN** the VMSS SHALL carry both `chaos-target=true` and `environment=<env>` tags alongside any pre-existing AKS-managed tags

#### Scenario: Tags merged with existing tags
- **WHEN** the module is deployed targeting a VMSS that already has AKS-managed tags (e.g., `aks-managed-createOperationID`)
- **THEN** the chaos tags SHALL be added and the existing tags SHALL be preserved unchanged

#### Scenario: Idempotent tag application
- **WHEN** the module is deployed twice with the same parameters
- **THEN** the VMSS tag set SHALL be identical after both runs and no deployment error SHALL occur

---

### Requirement: chaos.bicep loops over all provided VMSS names to apply tags
`chaos.bicep` SHALL accept a `vmssNames` string array parameter and deploy `chaos-vmss-tags.bicep` for each entry, scoped to the node resource group.

#### Scenario: Multiple VMSSes tagged in one deployment
- **WHEN** `chaos.bicep` is deployed with `vmssNames = ["aks-user-12345678-vmss", "aks-spot-87654321-vmss"]`
- **THEN** both VMSSes in the node resource group SHALL carry the chaos tags after deployment

#### Scenario: Invalid VMSS name fails fast
- **WHEN** a name in `vmssNames` does not correspond to an existing VMSS in the node resource group
- **THEN** the Bicep deployment SHALL fail with a resource-not-found error before the experiment resource is created
