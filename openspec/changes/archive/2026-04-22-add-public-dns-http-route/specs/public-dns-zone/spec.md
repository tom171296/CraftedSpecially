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
The AKS cluster SHALL use the Bicep-provisioned static public IP for the Envoy Gateway LoadBalancer Service. This SHALL be configured via an `EnvoyProxy` custom resource referenced from the `Gateway` resource's `infrastructure.parametersRef`.

#### Scenario: Gateway Service claims the static IP
- **WHEN** ArgoCD syncs the `EnvoyProxy` and updated `Gateway` resources
- **THEN** the Envoy Gateway LoadBalancer Service is assigned the static public IP via the `service.beta.kubernetes.io/azure-load-balancer-ipv4` annotation

#### Scenario: EnvoyProxy scoped to this Gateway only
- **WHEN** the `EnvoyProxy` is referenced from `spec.infrastructure.parametersRef` on the Gateway
- **THEN** only the `craftedspecially-gateway` LoadBalancer Service is affected; other Gateways in the cluster are not changed
