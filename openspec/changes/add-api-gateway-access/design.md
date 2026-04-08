## Context

CraftedSpecially runs on AKS with workload identity and OIDC enabled. The cluster currently has no external ingress layer; services are only reachable inside the cluster. The infrastructure is designed to be cloud-agnostic and CNCF-aligned, avoiding vendor lock-in.

The API gateway must be deployed on the cluster (not as a managed Azure service) so it can be moved to other Kubernetes environments. It must integrate with the existing Bicep-managed AKS cluster and support TLS termination and path/host-based routing.

## Goals / Non-Goals

**Goals:**
- Single external entry point for HTTP/HTTPS traffic into the cluster
- Path- and host-based routing to internal services using the Kubernetes Gateway API
- TLS termination at the gateway
- Deployable via Helm alongside the existing Bicep infrastructure
- Cloud-agnostic: runs on any conformant Kubernetes cluster

**Non-Goals:**
- Authentication / authorisation enforcement (future capability)
- Rate limiting or WAF rules (future capability)
- Service mesh (mTLS between services)
- Replacing Azure Load Balancer; the gateway sits behind it
- Using the legacy `networking.k8s.io/v1 Ingress` API

## Decisions

### D1 – Route model: Kubernetes Gateway API (`gateway.networking.k8s.io`)

**Choice**: Use the Kubernetes Gateway API (`GatewayClass`, `Gateway`, `HTTPRoute`) as the route model.

**Rationale**: The Gateway API is the official successor to the `Ingress` API, graduated to GA in Kubernetes 1.28+. It provides first-class role separation (infrastructure provider owns `GatewayClass`/`Gateway`; app teams own `HTTPRoute`), richer routing semantics, and is the direction the Kubernetes community is standardising on. Using it now avoids a future migration away from the legacy Ingress API.

---

### D2 – Gateway controller: Envoy Gateway

**Choice**: `envoy-gateway` (CNCF, co-developed alongside the Gateway API spec)

**Rationale**: Envoy Gateway is the reference implementation of the Kubernetes Gateway API. It was designed in parallel with the spec, giving it the strongest conformance of any available controller. The Envoy data plane is battle-tested at scale (it also underpins Istio and Contour), and the project is CNCF-hosted with no vendor affiliation. It also provides a natural upgrade path toward a service mesh if one is needed later.

**Alternatives considered**:
- *Traefik*: Mature and widely deployed, but Gateway API is a secondary UX (primary is `IngressRoute` CRDs); conformance lags behind Envoy Gateway.
- *NGINX Gateway Fabric*: Purpose-built for Gateway API but tied to the NGINX data plane; fewer extensibility options than Envoy.
- *ingress-nginx (Gateway API experimental)*: Support is experimental and incomplete; the project itself recommends migrating to a Gateway-API-native controller.
- *Azure API Management*: Managed service; contradicts the cloud-agnostic constraint.

---

### D3 – TLS: cert-manager with Let's Encrypt (staging first, prod on demand)

**Choice**: Deploy `cert-manager` alongside Envoy Gateway; use `ClusterIssuer` backed by Let's Encrypt. The `Gateway` resource references a TLS secret managed by cert-manager via a `Certificate` object.

**Rationale**: Automated certificate lifecycle without manual renewal. cert-manager has native support for the Gateway API via its `gateway.cert-manager.io/v1` integration, making it the natural pairing.

---

### D4 – Azure-side networking: use the AKS-managed public load balancer

**Choice**: Allow NGINX Gateway Fabric to provision a `LoadBalancer` service via the AKS cloud-controller-manager. No additional Bicep networking changes are required for a basic setup.

**Rationale**: AKS already provisions a managed public load balancer for `LoadBalancer`-type services. This is the lowest-complexity path for the initial implementation. A dedicated public IP can be pinned in a follow-up if a stable IP address is required.

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| Envoy xDS concepts surface when debugging routing issues | Use `envoy-gateway` CLI and the admin API (`/config_dump`) for diagnostics; document in runbook |
| Gateway API CRDs must be installed cluster-wide before the controller | Install CRDs as a pre-step; document in runbook |
| Let's Encrypt rate limits during development | Use Let's Encrypt *staging* issuer until production readiness |
| Azure LB IP changes on controller pod restart | Pin a static public IP via `service.beta.kubernetes.io/azure-pip-name` annotation if stability is needed |
| cert-manager + Gateway API integration requires the `cert-manager.io/gateway-api` feature gate | Enable via Helm values at deploy time; document the flag |

## Migration Plan

1. Install Gateway API CRDs (`kubectl apply -f gateway-api/standard-install.yaml`)
2. Deploy cert-manager via Helm into `cert-manager` namespace with Gateway API feature gate enabled
3. Deploy Envoy Gateway via Helm into `envoy-gateway-system` namespace
4. Apply `GatewayClass` and `Gateway` resources; confirm `LoadBalancer` external IP is assigned
5. Apply `ClusterIssuer` for Let's Encrypt staging and a `Certificate` object bound to the `Gateway`
6. Deploy a test `HTTPRoute` pointing to an existing service to validate end-to-end routing
7. Switch `ClusterIssuer` to Let's Encrypt production once validated
8. Update Bicep outputs to expose the gateway's public IP for DNS configuration

**Rollback**: Delete the Envoy Gateway and cert-manager Helm releases and the Gateway API CRDs. No changes to existing application workloads are required; they remain reachable on internal cluster DNS.

## Open Questions

- Should a static public IP be pre-provisioned in Bicep so DNS can be set up before the first deploy?
- Is a custom domain name available, or will the cluster IP be used directly for initial testing?
- Are there namespace or RBAC constraints that require the gateway controller to live in a specific namespace?
