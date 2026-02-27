## ADDED Requirements

### Requirement: AKS identity has Network Contributor on the resource group
The AKS cluster's system-assigned managed identity SHALL be granted the `Network Contributor` built-in role scoped to the `CraftedSpecially` resource group, so AKS cloud-controller-manager can claim the pre-provisioned static public IP and manage Load Balancer resources.

#### Scenario: Role assignment exists after Bicep deployment
- **WHEN** the Bicep deployment for `deployRuntimeInfrastructure` completes
- **THEN** a role assignment for `Network Contributor` (role ID `4d97b98b-1d4f-4787-a291-c67834d212e5`) exists on the `CraftedSpecially` resource group with the principal being the AKS cluster's system-assigned managed identity object ID

#### Scenario: Envoy Gateway LoadBalancer Service binds the static IP
- **WHEN** the `craftedspecially-gateway` Gateway resource is applied to the cluster
- **THEN** the Envoy Gateway LoadBalancer Service receives the external IP matching the pre-provisioned `CraftedSpecially-pip` public IP address within 5 minutes

#### Scenario: Static IP persists across Gateway Service re-creation
- **WHEN** the Envoy Gateway LoadBalancer Service is deleted and re-created
- **THEN** the same static IP address is re-assigned to the new Service without manual intervention

### Requirement: Public IP provisioned in the correct resource group
The static public IP resource SHALL reside in the `CraftedSpecially` resource group (not the AKS node resource group `MC_*`), and its name SHALL match the value in the `azure-pip-name` annotation on the EnvoyProxy Service.

#### Scenario: Public IP name matches annotation
- **WHEN** the EnvoyProxy CR is inspected
- **THEN** the `service.beta.kubernetes.io/azure-pip-name` annotation value matches the name of the public IP resource in the `CraftedSpecially` resource group

#### Scenario: Public IP resource group matches annotation
- **WHEN** the EnvoyProxy CR is inspected
- **THEN** the `service.beta.kubernetes.io/azure-load-balancer-resource-group` annotation value is `CraftedSpecially`
