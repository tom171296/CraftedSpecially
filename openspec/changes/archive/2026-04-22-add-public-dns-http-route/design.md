## Context

The project runs on AKS with Envoy Gateway as the Kubernetes Gateway API implementation. Envoy Gateway creates an Azure LoadBalancer `Service` that receives a dynamic public IP from Azure. Currently no domain name is configured: the `craftedspecially-api` HTTPRoute has empty `hostnames`, the cert-manager `Certificate` has no `dnsNames`, and no stable public address exists.

This is a demo project. The goal is the simplest possible stable public URL that requires zero external dependencies — no domain registrar, no DNS zone, no delegation.

## Goals / Non-Goals

**Goals:**
- Produce a stable, publicly resolvable FQDN for the application using only Azure-managed infrastructure.
- Populate the `hostnames` field of the HTTPRoute so Gateway API routes traffic by domain name.
- Populate `dnsNames` in the cert-manager Certificate so Let's Encrypt can issue a certificate.
- Keep everything in Bicep + existing Kubernetes manifests — no new operators.

**Non-Goals:**
- Custom domain registration or registrar delegation.
- Azure DNS Zone or private DNS.
- Multi-region or geo-redundant DNS.
- Migrating from Let's Encrypt staging to production (follow-on task after validation).

## Decisions

### Use Azure Public IP `domainNameLabel` instead of a custom DNS zone

**Decision**: Set `domainNameLabel` on the Static Public IP Bicep resource. Azure automatically provides an FQDN of the form `<label>.<region>.cloudapp.azure.com` at no cost and with immediate public resolution — no NS delegation needed.

**Why not Azure DNS Zone?** A custom DNS zone requires owning a domain, updating NS records at a registrar, and waiting up to 48 h for delegation to propagate. For a demo project this overhead is unnecessary. The `cloudapp.azure.com` subdomain resolves publicly the moment the IP is allocated.

**Why not a dynamic IP?** The Envoy Gateway LoadBalancer gets a new IP each time the Service is recreated. A static IP breaks the circular dependency: Bicep creates the IP (and thus the FQDN), and the Kubernetes manifests can reference that FQDN before the cluster is live.

**Alternatives considered:**
- *Azure DNS Zone*: Fully custom domain, but needs registrar + delegation. Deferred — can be added later by pointing a CNAME at the `cloudapp.azure.com` address.
- *External-DNS operator*: GitOps-native auto-sync, but adds an operator and Azure DNS RBAC. Deferred.

### Configure static IP on the Gateway via `EnvoyProxy` + `infrastructure.parametersRef`

**Decision**: Create an `EnvoyProxy` resource (Envoy Gateway CRD) that sets the `service.beta.kubernetes.io/azure-load-balancer-ipv4` annotation on the generated LoadBalancer Service. Reference it from the Gateway via `spec.infrastructure.parametersRef`.

**Why not annotate the Gateway directly?** The Envoy Gateway controller generates the LoadBalancer `Service` — annotations on the `Gateway` resource itself are not forwarded to the Service. The `EnvoyProxy` API is the supported extension point for customising the generated Service.

**Why not modify GatewayClass?** GatewayClass-level `parametersRef` applies the proxy config to all Gateways in the cluster. A Gateway-level reference is more scoped and won't affect future gateways.

### HTTP-01 ACME challenge (retain existing)

**Decision**: Keep the existing HTTP-01 ClusterIssuers. Once the domain resolves publicly to the cluster IP, cert-manager can complete the ACME challenge without additional changes.

**Why not DNS-01?** DNS-01 would allow wildcard certs, but requires cert-manager to have write access to a DNS zone — extra federated credential and role assignment. HTTP-01 is sufficient for a single-hostname certificate and is already wired up.

## Risks / Trade-offs

- **Label availability** → `domainNameLabel` must be unique within an Azure region. If the chosen label is taken, the Bicep deploy will fail with a conflict error. Mitigation: use a project-specific prefix (e.g., `craftedspecially-api`).
- **IP change on resource deletion** → If the Static Public IP Bicep resource is deleted and recreated, the FQDN label may be reassigned to a different IP. Mitigation: treat the IP as a long-lived resource; do not delete it during normal operations.
- **`cloudapp.azure.com` branding** → The FQDN includes Azure region and subdomain. Acceptable for a demo; a CNAME from a custom domain can be added later without changing any cluster config.

## Migration Plan

1. **Bicep**: Add `networking.bicep` module with static IP + `domainNameLabel` → deploy → note the FQDN from output.
2. **Kubernetes**: Create `EnvoyProxy` resource with the static IP annotation → update `gateway.yaml` with `infrastructure.parametersRef` → ArgoCD syncs → LoadBalancer IP is assigned.
3. **Kubernetes**: Set `hostnames` in HTTPRoute and `dnsNames` in Certificate using the FQDN from step 1 → update ClusterIssuer emails → ArgoCD syncs → cert-manager requests staging certificate.
4. **Verify**: Confirm FQDN resolves and HTTPS works with staging cert.
5. **Switch to production**: Update Certificate `issuerRef` to `letsencrypt-prod`.

**Rollback**: Remove `hostnames` from the HTTPRoute to stop hostname-based routing. The static IP is an additive Azure resource.

## Open Questions

- What `domainNameLabel` string should be used? Suggested: `craftedspecially-api` → `craftedspecially-api.<region>.cloudapp.azure.com`.
- What ACME contact email should be set on the ClusterIssuers? (Any real address works; Let's Encrypt uses it only for expiry notices.)
