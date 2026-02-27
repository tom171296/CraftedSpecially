## Why

The CraftedSpecially demo application is deployed to Azure Container Apps but lacks a stable, publicly accessible URL with a custom domain. Setting up a public IP and Azure-managed DNS enables the demo to be reliably shared and accessed without relying on auto-generated hostnames.

## What Changes

- Provision a static public IP address in Azure for the Container App environment
- Configure Azure DNS Zone to manage the domain name
- Map the custom domain to the Container App via DNS records and CNAME/A record binding
- Add managed TLS certificate for HTTPS access

## Capabilities

### New Capabilities

- `azure-dns-zone`: Azure DNS Zone resource managing the domain, including A/CNAME records pointing to the Container App's public IP
- `azure-public-ip`: Static public IP address resource provisioned in Azure and associated with the Container App environment
- `container-app-custom-domain`: Custom domain binding on the Container App with managed TLS certificate

### Modified Capabilities

- `azure-app-config-integration`: No requirement changes — implementation only (infra Bicep references may be updated)

## Impact

- **Infrastructure (Bicep)**: New resources added to `infra/` — DNS Zone, Public IP, and custom domain binding on Container App environment
- **Container App**: Custom domain configured; traffic routed through the new DNS zone
- **Dependencies**: Requires a registered domain name to delegate to the Azure DNS Zone
