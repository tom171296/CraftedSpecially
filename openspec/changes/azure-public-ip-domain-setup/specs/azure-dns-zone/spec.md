## ADDED Requirements

### Requirement: Azure DNS Zone provisioned via Bicep
The infrastructure SHALL include an `Microsoft.Network/dnsZones` resource deployed through a new Bicep module at `infra/modules/runtime_infrastructure/networking/dns.bicep`. The DNS Zone SHALL be created in the same resource group as the rest of the runtime infrastructure.

#### Scenario: DNS Zone created on first deployment
- **WHEN** `az deployment sub create` is run with the updated Bicep stack
- **THEN** an Azure DNS Zone resource exists in the resource group with the configured domain name

#### Scenario: DNS Zone outputs nameservers
- **WHEN** the Bicep deployment completes successfully
- **THEN** the DNS Zone module outputs the list of Azure nameserver hostnames so the operator can delegate from their registrar

### Requirement: A record linking domain to static public IP
The DNS Zone SHALL contain an A record at the apex (or a subdomain such as `api`) that points to the static public IP address provisioned for the AKS Envoy Gateway LoadBalancer.

#### Scenario: A record resolves to the static IP
- **WHEN** the deployment completes and NS delegation is in place at the registrar
- **THEN** `nslookup <domain>` returns the static IP address provisioned in Azure

#### Scenario: A record is managed as Bicep resource
- **WHEN** the Bicep stack is redeployed
- **THEN** the A record is idempotently updated to reflect the current static IP value
