## ADDED Requirements

### Requirement: Envoy proxy service deployed as Azure Internal Load Balancer
The `EnvoyProxy` custom resource SHALL configure the Envoy Gateway LoadBalancer Service as an Azure Internal Load Balancer by setting the `service.beta.kubernetes.io/azure-load-balancer-internal: "true"` annotation. A fixed private IP from the AKS node subnet SHALL be assigned via the `service.beta.kubernetes.io/azure-load-balancer-ipv4` annotation so that the internal endpoint is stable across pod restarts.

#### Scenario: Envoy service receives a private IP
- **WHEN** ArgoCD syncs the updated `EnvoyProxy` resource
- **THEN** AKS provisions an Azure Internal Load Balancer for the Envoy service with the configured private IP and no public IP is assigned to the service

#### Scenario: Internal LB is not reachable from the internet
- **WHEN** a TCP connection is attempted from outside the VNet directly to the Envoy internal LB private IP
- **THEN** the connection is refused or times out because the private IP is not routable from the public internet

#### Scenario: Internal LB is reachable from within the VNet
- **WHEN** a request is made from within the AKS VNet (e.g., another pod or an Azure resource in the same VNet) to the Envoy internal LB private IP on port 80 or 443
- **THEN** the request is forwarded to an Envoy proxy pod

### Requirement: Bicep-managed Azure Public Load Balancer routes internet traffic to the Envoy internal LB
The `networking.bicep` module SHALL provision a Standard Azure Public Load Balancer with the static public IP as its frontend IP configuration. The LB SHALL use an IP-based backend pool targeting the Envoy internal LB private IP directly, with load-balancing rules that forward TCP port 80 and TCP port 443 from the public frontend to the internal LB on the same ports respectively.

#### Scenario: HTTP traffic forwarded to Envoy via the public LB
- **WHEN** a TCP request arrives at the static public IP on port 80
- **THEN** the Azure Public Load Balancer routes the request to the Envoy internal LB private IP on port 80, which forwards it to an Envoy proxy pod

#### Scenario: HTTPS traffic forwarded to Envoy via the public LB
- **WHEN** a TCP request arrives at the static public IP on port 443
- **THEN** the Azure Public Load Balancer routes the request to the Envoy internal LB private IP on port 443, which forwards it to an Envoy proxy pod

#### Scenario: Public LB health probe confirms Envoy availability
- **WHEN** the Azure Public Load Balancer sends a TCP health probe to the Envoy internal LB private IP on port 80
- **THEN** the probe succeeds only when the Envoy proxy is reachable via the internal LB, ensuring the backend is marked unhealthy if Envoy is down

### Requirement: Bicep networking module provisions a user-managed VNet with an AKS node subnet
The `networking.bicep` module SHALL provision a Standard Azure Virtual Network with a dedicated subnet for AKS node pools. The subnet address space SHALL be sized to accommodate all node pools and reserve a static private IP for the Envoy internal LB at the high end of the range (default: `10.0.1.200` in `10.0.1.0/24`). This VNet enables the Bicep-managed Public Load Balancer to reference the Envoy internal LB IP via an IP-based backend pool.

#### Scenario: VNet and AKS subnet created on first deploy
- **WHEN** the `runtime_infrastructure` Bicep deployment runs
- **THEN** a Standard Azure Virtual Network and an AKS nodes subnet exist in the resource group with the configured address prefixes

#### Scenario: AKS node pools deployed into the user-managed subnet
- **WHEN** the AKS cluster is provisioned with `vnetSubnetID` set to the AKS nodes subnet ID
- **THEN** all AKS node pool VMs receive IP addresses from within the `10.0.1.0/24` subnet range

### Requirement: Bicep networking module emits internal LB private IP as output
The `networking.bicep` module SHALL emit the configured Envoy internal LB private IP as a Bicep output (`envoyInternalIp`) so it is available for downstream configuration and documentation.

#### Scenario: Internal IP output available after deployment
- **WHEN** the `runtime_infrastructure` Bicep deployment completes
- **THEN** the deployment output `envoyInternalIp` contains the private IP address assigned to the Envoy Internal Load Balancer
