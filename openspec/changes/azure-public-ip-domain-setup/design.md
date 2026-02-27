## Context

CraftedSpecially runs on AKS with Envoy Gateway as the ingress controller and cert-manager for TLS. The HTTPRoute and Certificate manifests already have `TODO` placeholders for a real FQDN but currently reference a placeholder `cloudapp.azure.com` hostname. There is no Azure DNS Zone resource in the Bicep stack, and the public IP used by the Envoy Gateway LoadBalancer Service is dynamically allocated.

The goal is to replace the dynamic, auto-generated hostname with a stable custom domain backed by an Azure DNS Zone, so the demo can be shared via a predictable URL.

## Goals / Non-Goals

**Goals:**
- Provision a static public IP in Azure and link it to the Envoy Gateway LoadBalancer Service
- Create an Azure DNS Zone and an A record pointing the custom domain to that static IP
- Update the Kubernetes Certificate and HTTPRoute to use the custom domain
- Switch cert-manager ClusterIssuer from staging to production Let's Encrypt

**Non-Goals:**
- Domain registrar configuration (delegating NS records to Azure DNS is a manual step — documented, not automated)
- Multi-region or geo-redundant DNS setup
- Wildcard certificate support

## Decisions

### Static Public IP over FQDN label on dynamic IP

**Decision**: Provision a `Microsoft.Network/publicIPAddresses` resource (static allocation) and annotate the Envoy Gateway Service to use it via `service.beta.kubernetes.io/azure-load-balancer-resource-group` + `loadBalancerIP`.

**Rationale**: A static IP means the DNS A record never drifts even if the AKS cluster is recreated. The alternative — using the Azure FQDN label on a dynamic IP — couples the hostname to Azure's naming scheme (`*.region.cloudapp.azure.com`) and doesn't allow a custom domain.

### Azure DNS Zone in runtime_infrastructure module

**Decision**: Add the DNS Zone and A record to `infra/modules/runtime_infrastructure/` as a new `networking/dns.bicep` module.

**Rationale**: DNS is runtime infrastructure alongside AKS, observability, and configuration management. Keeping it in `runtime_infrastructure` avoids touching the existing module boundaries.

### Let's Encrypt HTTP-01 challenge (keep existing solver)

**Decision**: Retain the HTTP-01 ACME solver via Envoy Gateway HTTPRoute that is already configured in `cluster-issuer-*.yaml`.

**Rationale**: The HTTP-01 solver works without additional Azure DNS API access. DNS-01 would allow wildcard certs but adds complexity (Azure Managed Identity for cert-manager, DNS zone contributor role). For a demo project, HTTP-01 is sufficient.

## Risks / Trade-offs

- **NS delegation is manual** → Document the `az network dns zone show --query nameServers` command in the task list so the operator can copy nameservers to their registrar. Without this step the domain won't resolve.
- **Static IP quota** → Azure subscriptions have a default limit on static public IPs per region. Mitigation: the demo uses one IP, well within limits.
- **Cluster recreate orphans the IP** → Static IP is provisioned outside the node resource group, so AKS deletion won't release it. This is desirable for persistence but requires manual cleanup if the project is torn down.

## Migration Plan

1. Run `az deployment sub create` with the updated Bicep to provision the static IP and DNS Zone.
2. Note the nameservers output and configure NS records at the domain registrar.
3. Apply updated Kubernetes manifests (Certificate, HTTPRoute, ClusterIssuer).
4. Verify cert-manager issues a valid certificate (`kubectl get certificate -n envoy-gateway-system`).
5. **Rollback**: Revert the HTTPRoute hostname to the previous placeholder — the old `cloudapp.azure.com` address is unchanged. Delete the Bicep resources manually if needed.
