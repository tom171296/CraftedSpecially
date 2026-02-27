## ADDED Requirements

### Requirement: Static public IP resource provisioned in Azure
The infrastructure SHALL include a `Microsoft.Network/publicIPAddresses` resource with static allocation SKU Standard, deployed via Bicep in the same resource group as the AKS cluster.

#### Scenario: Static IP is allocated after deployment
- **WHEN** the Bicep deployment completes
- **THEN** a static public IP address resource exists in the resource group and its `ipAddress` property is populated

#### Scenario: IP persists across cluster operations
- **WHEN** AKS node pools are scaled or nodes are recycled
- **THEN** the public IP address value does not change

### Requirement: Envoy Gateway LoadBalancer Service uses the static IP
The AKS Envoy Gateway LoadBalancer Service SHALL be annotated to use the provisioned static public IP via the `service.beta.kubernetes.io/azure-load-balancer-resource-group` and `loadBalancerIP` fields (or equivalent current AKS annotation).

#### Scenario: LoadBalancer Service binds to static IP
- **WHEN** the annotated EnvoyProxy config is applied and the gateway is reconciled
- **THEN** `kubectl get svc -n envoy-gateway-system` shows the EXTERNAL-IP matching the static IP provisioned in Azure

#### Scenario: Static IP output available for Kubernetes configuration
- **WHEN** the Bicep deployment outputs the static IP address value
- **THEN** the operator can use the output to set `loadBalancerIP` in the EnvoyProxy manifest or via `az deployment` output piping
