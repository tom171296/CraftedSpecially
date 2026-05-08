## Context

The subscription-level deployment in infra/CraftedSpecially.bicep creates a tenant-scoped Service Group under an existing root Service Group. Core runtime and governance resources are provisioned via modules, but they are not yet explicitly attached as Service Group members.

The target resources to enroll are AKS, App Configuration, Key Vault, and Load Balancer. Membership is modeled through Microsoft.Relationships/serviceGroupMember resources scoped to each target resource with targetId set to the created Service Group resource ID.

## Goals / Non-Goals

**Goals:**
- Enroll AKS, App Configuration, Key Vault, and Load Balancer in the created Service Group as part of the same deployment flow.
- Keep deployments idempotent with deterministic relationship names and stable dependency order.
- Avoid hardcoding resource IDs by passing module outputs or resolving existing resources consistently.
- Ensure deployment validation (what-if/template validation) succeeds without manual post-steps.

**Non-Goals:**
- Changing Service Group hierarchy or parent resolution logic.
- Refactoring unrelated modules or resource naming conventions.
- Introducing new governance resources beyond required Service Group membership relationships.

## Decisions

1. Use `Microsoft.Relationships/serviceGroupMember@2023-09-01-preview` for all enrollments.
Rationale: This is the canonical relationship resource for Service Group membership and supports resource-scoped associations.
Alternative considered: Managing membership outside Bicep via CLI after deployment. Rejected because it breaks infrastructure-as-code parity and repeatability.

2. Add membership resources in the orchestration layer where Service Group is defined.
Rationale: The service group is created in infra/CraftedSpecially.bicep, making it the most direct place to attach cross-module resources.
Alternative considered: Embedding relationship creation inside each module. Rejected because relationships depend on a tenant-scoped resource defined at root and would increase cross-module coupling.

3. Surface required target resource identifiers as module outputs when not directly available.
Rationale: Membership needs resource scope for each target. Using outputs keeps references explicit and compile-time validated.
Alternative considered: Constructing IDs manually with string interpolation. Rejected due to brittleness across naming/location changes.

4. Use deterministic relationship names (`rel-aks`, `rel-appconfig`, `rel-keyvault`, `rel-loadbalancer`).
Rationale: Prevents accidental duplicate relationships and keeps updates predictable.
Alternative considered: Generated names from uniqueString. Rejected because it complicates drift and troubleshooting.

## Risks / Trade-offs

- [RBAC coverage may be incomplete] -> Mitigation: document required permissions for both Service Group management and target resource write scope; validate with what-if before apply.
- [Some target resources may not currently expose required outputs] -> Mitigation: add minimal outputs in modules and keep names aligned with existing resource declarations.
- [Load balancer resource discovery may vary depending on architecture] -> Mitigation: define one supported source of truth (module output or existing lookup) and defer unsupported topologies as follow-up.
- [Preview API version dependency] -> Mitigation: pin API versions and include validation steps in tasks.
