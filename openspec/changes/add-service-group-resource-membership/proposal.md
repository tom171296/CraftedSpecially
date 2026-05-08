## Why

The subscription deployment creates a Service Group, but key platform resources are not explicitly enrolled as members. Without membership, governance and service hierarchy views are incomplete, which reduces traceability and operational ownership clarity.

## What Changes

- Add Service Group membership relationships for core resources created by this deployment
- Enroll AKS, App Configuration, Key Vault, and Load Balancer resources into the created Service Group
- Add deterministic naming and dependency wiring for relationship resources to keep deployments idempotent
- Validate membership creation in subscription deployment and document required permissions

## Capabilities

### New Capabilities
- `azure-service-group-membership`: Adds and manages Service Group member relationships for platform resources using Bicep relationship resources in subscription deployments

### Modified Capabilities

## Impact

- **Infrastructure Code**: Updates in `infra/CraftedSpecially.bicep` and potentially module outputs in `infra/modules/runtime_infrastructure/**` and `infra/modules/management_governance/**`
- **Azure Governance**: Service Group membership will include AKS, App Configuration, Key Vault, and Load Balancer resources
- **Deployment Permissions**: Deployment identity must have rights to create `Microsoft.Relationships/serviceGroupMember` on target resources
- **APIs/Runtime**: No application API behavior changes; impact is governance metadata and resource organization
