## ADDED Requirements

### Requirement: Service Group membership relationships SHALL be created for core platform resources
The deployment system SHALL create Service Group membership relationships that attach AKS, App Configuration, Key Vault, and Load Balancer resources to the Service Group created in the same deployment.

#### Scenario: Membership relationships are provisioned during deployment
- **WHEN** a subscription deployment is executed with valid target resource references
- **THEN** the deployment creates Service Group member relationships for AKS, App Configuration, Key Vault, and Load Balancer with `targetId` set to the created Service Group ID

### Requirement: Membership creation SHALL be idempotent and deterministic
The deployment system SHALL use stable relationship resource names and stable target scopes so repeated deployments do not create duplicate or conflicting relationships.

#### Scenario: Re-deployment does not create duplicates
- **WHEN** the same deployment is applied multiple times with unchanged inputs
- **THEN** each target resource keeps exactly one deterministic Service Group member relationship in a succeeded state

### Requirement: Missing or invalid target resources MUST fail deployment with clear diagnostics
The deployment system MUST fail membership creation when a required target resource reference cannot be resolved or is invalid.

#### Scenario: Invalid target resource reference blocks apply
- **WHEN** a target resource identifier or scope is incorrect for AKS, App Configuration, Key Vault, or Load Balancer
- **THEN** deployment validation or apply fails with an error that identifies the failing membership relationship

### Requirement: Deployment identity MUST have sufficient permissions for relationship creation
The deployment system MUST require and validate that deployment identity has permissions to create Service Group membership relationships on each target scope.

#### Scenario: Insufficient permissions are surfaced
- **WHEN** deployment identity lacks required permissions on service group or target resources
- **THEN** deployment fails with authorization errors tied to the affected Service Group member relationship resources
