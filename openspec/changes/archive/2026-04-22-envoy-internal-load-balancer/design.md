## Context

Currently the `craftedspecially-gateway` in AKS is fronted by an Envoy Gateway LoadBalancer Service that is configured (via the `EnvoyProxy` CR) to receive the static public IP directly through the `service.beta.kubernetes.io/azure-load-balancer-ipv4` annotation. This means AKS creates an Azure **public** Load Balancer with the static IP on the envoy service, exposing port 80 and 443 directly from the internet to the proxy.

The networking Bicep module already provisions the static public IP resource and the AKS module provisions the cluster. The Bicep module does **not** currently provision any Azure Load Balancer resource separate from what AKS auto-manages.

The goal is to make the Envoy proxy service an Azure **internal** (private VNet) load balancer, while routing internet traffic to it via a Bicep-managed Azure Public Load Balancer that has the static IP as its frontend.

## Goals / Non-Goals

**Goals:**
- The Envoy proxy Kubernetes Service becomes an Azure Internal Load Balancer with a fixed, predictable private IP.
- A Bicep-managed Azure Standard Public Load Balancer fronts the static public IP and forwards TCP 80/443 to the AKS node pool backend (which routes via kube-proxy to the Envoy pods).
- Public DNS (FQDN) continues to resolve to the same static public IP — no changes to DNS or cert-manager configuration.
- The change is backward-compatible for all existing HTTPRoutes and TLS certificate issuance.

**Non-Goals:**
- No WAF, DDoS Protection Standard, or Application Gateway is introduced.
- No changes to cert-manager, HTTPRoute, or Gateway listener configuration.
- No multi-region or multi-cluster routing changes.

## Decisions

### Decision 1: Azure Internal Load Balancer via Kubernetes annotation (not Bicep-managed)
The Envoy service becomes an internal LB by adding `service.beta.kubernetes.io/azure-load-balancer-internal: "true"` to the `EnvoyProxy` CR's `envoyService.annotations`. A fixed private IP is assigned via `service.beta.kubernetes.io/azure-load-balancer-ipv4: "<private-ip>"` (a free IP from the AKS node subnet, e.g. `10.0.1.100`).

**Alternatives considered:**
- *Create the internal LB via Bicep* — AKS manages LB resources in the `MC_*` resource group; attempting to pre-create or co-manage an AKS LB in Bicep creates lifecycle conflicts and is not recommended.
- *Keep the public LB on Envoy and add a second internal service* — Envoy Gateway's `EnvoyProxy` CR only provisions one service; a separate Kubernetes Service would bypass the gateway controller.

### Decision 2: Bicep-managed Azure Public Standard Load Balancer as the internet entry point
A new `Microsoft.Network/loadBalancers` resource is added to `networking.bicep` with:
- Frontend IP config: the existing static public IP
- Backend pool: AKS node pool NIC IPs (referenced by the AKS subnet)
- Health probe: TCP on port 80
- Load-balancing rules: TCP 80 → node port 80, TCP 443 → node port 443

The node ports on the Kubernetes side are fixed by setting `spec.ports[].nodePort` in the Envoy service (via `EnvoyProxy` CR `ports` field) to well-known values (e.g., 30080 for HTTP, 30443 for HTTPS) so the Bicep LB rules can reference stable ports.

**Alternatives considered:**
- *Azure Application Gateway* — Adds L7 capability and WAF but is significantly more expensive and complex for this use case.
- *Azure Front Door* — Global CDN/WAF, out of scope and over-engineered for a single-region setup.
- *Keep AKS-managed public LB; add the static IP as an additional frontend* — AKS does not support adding custom frontend IPs to its managed public LB through Kubernetes service annotations on unrelated services; requires low-level Azure API manipulation.

### Decision 3: Fixed private IP sourced from Bicep output
The private IP assigned to the internal LB (e.g., `10.0.1.100`) must be within the AKS node subnet CIDR and not collide with DHCP-assigned node IPs. It is added as a Bicep parameter (`envoyInternalIp`) with a default value, and passed through to K8s manifest configuration (via ArgoCD `ApplicationSet` values or Helm values).

## Risks / Trade-offs

- **Backend pool membership** — The Bicep Public LB backend pool targets AKS node NICs. When AKS scales or replaces nodes (upgrades, autoscaler), the backend pool must stay in sync. AKS does not automatically update a separately-managed LB's backend pool. Mitigation: use the AKS-managed NIC IP Group or the AKS `agentpool` subnet as the backend pool (via `loadBalancerBackendAddressPools` referencing the subnet, which Azure supports for Standard LBs). Alternatively, adopt Azure NAT Gateway or a NodePool-level outbound rule. If this proves fragile, fall back to Application Gateway.
- **Fixed NodePort values** — Requiring stable node ports (30080/30443) constrains the port range. Mitigation: pick ports outside the default ephemeral range and document the values.
- **Double-hop latency** — Traffic traverses the Bicep Public LB → AKS node → internal LB → Envoy pod (two LB hops). The latency impact is negligible for typical web traffic but should be noted.
- **Static private IP availability** — The chosen private IP (`10.0.1.100`) must be reserved/outside the DHCP pool. Mitigation: document the reserved IP and enforce it in networking naming conventions.

## Migration Plan

1. Add the `envoyInternalIp` Bicep parameter and extend `networking.bicep` with the Azure Public LB resource.
2. Deploy updated Bicep — the public LB is created with the static IP. Existing traffic continues to use the AKS-managed public LB on the Envoy service until step 4.
3. Update `envoy-proxy.yaml` with internal LB annotations and fixed node ports.
4. ArgoCD syncs the updated `EnvoyProxy` — AKS re-creates the Envoy LoadBalancer Service as internal. **Brief downtime expected** during service recreation (~30–60 seconds).
5. Verify the Bicep Public LB health probe turns green and traffic reaches Envoy via the new path.
6. **Rollback**: Re-apply the previous `envoy-proxy.yaml` (removes internal LB annotation, re-assigns public IP); delete the Bicep Public LB resource via `az resource delete`.

## Open Questions

- What private IP should be reserved for the Envoy internal LB? Needs to be confirmed against the AKS node subnet CIDR. *(Default assumption: `10.0.1.100`)*
- Should the Bicep Public LB use a health probe on port 80 or a custom Envoy admin endpoint? *(Default: TCP port 80)*
- Is the AKS node subnet accessible to the separately-managed Bicep LB backend pool, or does the LB need to be deployed into the same VNet? *(Requires confirming AKS VNet details.)*
