## Context

The cluster runs Envoy Gateway on AKS. Envoy Gateway creates a Kubernetes `Service` of type `LoadBalancer`; AKS's cloud-controller-manager then provisions (or claims) an Azure Load Balancer and public IP for that Service. A pre-provisioned static public IP (`CraftedSpecially-pip`, Standard SKU) already exists in the `CraftedSpecially` resource group, created by Bicep.

The EnvoyProxy CR already carries the annotations to claim that IP:

```yaml
service.beta.kubernetes.io/azure-pip-name: "CraftedSpecially-pip"
service.beta.kubernetes.io/azure-load-balancer-resource-group: "CraftedSpecially"
```

What is missing:

1. The AKS cluster's managed identity is not granted permissions on the `CraftedSpecially` RG, so AKS cannot claim an IP it doesn't own.
2. HTTPRoute hostnames are stale/inconsistent and do not match the actual FQDN produced by the Bicep-provisioned IP.
3. There is no path-based routing strategy: both services are declared at path prefix `/`, which causes conflicts and makes it impossible to expose both from one hostname.
4. The cert-manager Certificate does not explicitly cover both routes.

## Goals / Non-Goals

**Goals:**
- AKS cluster identity has least-privilege RBAC to claim the static IP.
- A single public IP and Gateway listener serves both ArgoCD (`/argocd`) and the CraftedSpecially API (`/api`).
- All hostnames reference the FQDN derived from the Bicep-deployed IP, eliminating hard-coded region strings.
- TLS is terminated at the Gateway for the shared hostname.

**Non-Goals:**
- Custom domain name or Azure DNS zone management.
- Exposing additional services through the Gateway.
- Changing the ArgoCD installation approach (Helm-via-ArgoCD app-of-apps stays as-is).

## Decisions

### D1 — Path-based routing over hostname-based routing

**Decision:** Route `/argocd/*` to ArgoCD and `/api/*` to the CraftedSpecially API on the same hostname (the pip FQDN).

**Rationale:** The project has a single static IP and no custom DNS zone. Creating a second Azure public IP just to get a second FQDN is wasteful. Path-based routing requires no additional Azure resources. ArgoCD supports a root path prefix via `server.rootpath`.

**Alternative considered:** Two public IPs, two FQDNs, two Gateway listeners — rejected because it doubles infrastructure cost and complexity for a demo project.

### D2 — Network Contributor on the resource group, not just the IP resource

**Decision:** Assign `Network Contributor` to the AKS system-assigned managed identity scoped to the `CraftedSpecially` resource group.

**Rationale:** AKS cloud-controller-manager needs to read/write Load Balancer rules, backend pools, and the public IP. Scoping only to the IP resource is insufficient; it also needs the Load Balancer resource (which lives in the same RG). `Network Contributor` is the minimal built-in role that covers all three.

**Alternative considered:** Custom role with narrower permissions — viable long-term but over-engineered for a demo.

### D3 — Derive hostname at deploy-time from Bicep output, not hard-coded in manifests

**Decision:** Keep the FQDN as a placeholder comment in manifests and document the `az deployment` command to retrieve the actual value. Do not hard-code region strings.

**Rationale:** The region is a Bicep parameter (`canadacentral` by default, overridable). Hard-coding `eastus` in route manifests causes silent mismatches. The operationally correct approach is to substitute the value from `outputs.gatewayFqdn` after Bicep deployment.

**Alternative considered:** Helm templating or Kustomize variable substitution — valid but adds toolchain complexity not yet present in this repo.

### D4 — ArgoCD path prefix via `server.rootpath`

**Decision:** Set `server.rootpath: /argocd` in ArgoCD Helm values so the UI and API self-references use the correct prefix.

**Rationale:** Without this, ArgoCD generates links and redirects that assume it is at `/`, breaking navigation when served under a subpath.

## Risks / Trade-offs

- **ArgoCD subpath compatibility** → ArgoCD v2.x supports `server.rootpath` but some older UI links may still break. Mitigation: test the UI after deploy; fall back to a dedicated hostname if subpath causes persistent issues.
- **Network Contributor scope is broad** → Granting RG-level Network Contributor means AKS can modify any network resource in the RG. Mitigation: acceptable for a demo project; scope can be narrowed to a custom role before production.
- **FQDN substitution is manual** → Operators must run the `az deployment` command and update manifests by hand. Mitigation: document the command clearly; automate in CI when the project matures.
- **Single IP is a single point of failure for all external traffic** → Both ArgoCD and the API go down together if the IP or LB has issues. Mitigation: accepted trade-off for a demo.

## Migration Plan

1. Apply the Bicep RBAC change (`az deployment group create ...`) — AKS identity immediately gains permissions.
2. Update ArgoCD Helm values (`server.rootpath: /argocd`) and sync the ArgoCD app.
3. Retrieve the actual FQDN from Bicep outputs and update HTTPRoute hostnames in both `routes.yaml` files.
4. Reconcile cert-manager Certificate to cover the shared FQDN; wait for cert issuance.
5. Apply updated HTTPRoute manifests via ArgoCD sync.
6. Verify: `curl https://<fqdn>/argocd` redirects to ArgoCD UI; `curl https://<fqdn>/api/health` returns 200.

**Rollback:** Revert HTTPRoute manifests to previous hostnames and remove the ArgoCD rootpath value. The RBAC role assignment is additive and harmless to leave in place.

## Open Questions

- Should `/` (bare root) return a landing page or 404? Currently unrouted — can be left as a 404 from Envoy for now.
- Is `canadacentral` the permanent region, or will this be deployed to multiple regions in future? Affects whether a custom domain + Traffic Manager makes more sense long-term.
