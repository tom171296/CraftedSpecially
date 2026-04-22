## ADDED Requirements

### Requirement: Static Public IP with Azure-managed DNS label provisioned via Bicep
The infrastructure SHALL provision an Azure Static Public IP resource with a `domainNameLabel` property using a Bicep module under `infra/modules/runtime_infrastructure/networking/`. No external DNS zone or registrar delegation is required.

#### Scenario: Static public IP created on first deploy
- **WHEN** the `runtime_infrastructure` Bicep deployment runs
- **THEN** an Azure Static Public IP resource (Standard SKU, Static allocation) exists in the resource group with the configured `domainNameLabel`

#### Scenario: Azure-managed FQDN available immediately after deploy
- **WHEN** the static public IP is allocated with a `domainNameLabel`
- **THEN** the FQDN `<domainNameLabel>.<region>.cloudapp.azure.com` resolves publicly to the static IP address without any additional DNS configuration

#### Scenario: FQDN emitted as Bicep output
- **WHEN** the Bicep deployment completes
- **THEN** the full FQDN is emitted as a deployment output so it can be used in Kubernetes manifests

#### Scenario: IP survives cluster node pool recreation
- **WHEN** an AKS node pool is upgraded or recreated
- **THEN** the static IP remains allocated and the FQDN continues to resolve to the same address

### Requirement: Static public IP assigned to Envoy Gateway LoadBalancer via EnvoyProxy
The static public IP SHALL be assigned as the frontend IP of the Bicep-managed Azure Public Load Balancer, NOT directly to the Envoy Gateway LoadBalancer Kubernetes Service. The `EnvoyProxy` custom resource SHALL no longer carry the `service.beta.kubernetes.io/azure-load-balancer-ipv4` annotation with the public IP address; instead it SHALL carry the private IP of the internal load balancer. The public IP remains the externally-visible address that DNS resolves to.

#### Scenario: Public LB frontend claims the static IP
- **WHEN** the `runtime_infrastructure` Bicep deployment runs
- **THEN** the Bicep-managed Azure Standard Public Load Balancer has a frontend IP configuration referencing the static public IP resource, and the Envoy Gateway LoadBalancer Service does NOT have the public IP as its assigned IP

#### Scenario: EnvoyProxy no longer holds the public IP annotation
- **WHEN** ArgoCD syncs the updated `EnvoyProxy` resource
- **THEN** the Envoy service has the `service.beta.kubernetes.io/azure-load-balancer-internal: "true"` annotation and a private IP, and the `service.beta.kubernetes.io/azure-load-balancer-ipv4` annotation value is a private VNet IP, not the public static IP

#### Scenario: EnvoyProxy scoped to this Gateway only
- **WHEN** the `EnvoyProxy` is referenced from `spec.infrastructure.parametersRef` on the Gateway
- **THEN** only the `craftedspecially-gateway` LoadBalancer Service is affected; other Gateways in the cluster are not changed
