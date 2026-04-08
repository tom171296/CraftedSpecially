## ADDED Requirements

### Requirement: External HTTP/HTTPS access via Kubernetes Gateway API
The cluster SHALL expose application workloads to external clients using the Kubernetes Gateway API (`gateway.networking.k8s.io`). Route definitions MUST use `HTTPRoute` resources. All external traffic MUST be routed through the `Gateway`; services SHALL NOT expose `LoadBalancer` or `NodePort` services directly.

#### Scenario: HTTP request reaches an application service
- **WHEN** an external client sends an HTTP request to the `Gateway`'s public endpoint matching a configured `HTTPRoute` host/path rule
- **THEN** the gateway forwards the request to the corresponding backend service and returns the response to the client

#### Scenario: HTTPS request with valid TLS certificate
- **WHEN** an external client sends an HTTPS request to the `Gateway`'s public endpoint
- **THEN** the gateway terminates TLS using a valid, automatically-renewed certificate and proxies the request to the backend service

#### Scenario: Request with no matching HTTPRoute rule
- **WHEN** an external client sends a request that does not match any configured `HTTPRoute`
- **THEN** the gateway returns HTTP 404

---

### Requirement: GatewayClass and Gateway resource configuration
A `GatewayClass` resource SHALL be configured to reference the Envoy Gateway controller. A `Gateway` resource SHALL be bound to that `GatewayClass` and SHALL define listeners for HTTP (port 80) and HTTPS (port 443).

#### Scenario: GatewayClass is accepted by the controller
- **WHEN** a `GatewayClass` referencing the Envoy Gateway controller name (`gateway.envoyproxy.io/gatewayclass-controller`) is applied
- **THEN** the controller sets the `GatewayClass` status condition `Accepted` to `True`

#### Scenario: Gateway listener is programmed
- **WHEN** a `Gateway` resource bound to the accepted `GatewayClass` is applied with HTTP and HTTPS listeners
- **THEN** the controller sets the `Gateway` status condition `Programmed` to `True` and the `LoadBalancer` service receives an external IP

---

### Requirement: HTTPRoute-based path- and host-based routing
Application teams SHALL configure routing using `HTTPRoute` resources attached to the `Gateway`. Routes MUST support both hostname-based and path-prefix-based matching.

#### Scenario: Host-based routing to separate services
- **WHEN** two `HTTPRoute` objects are configured with different `hostnames` attached to the same `Gateway`
- **THEN** requests to each hostname are independently routed to their respective backend services

#### Scenario: Path-prefix routing within a single host
- **WHEN** an `HTTPRoute` defines multiple path-prefix match rules under the same hostname
- **THEN** each path prefix is routed to its designated backend `Service`

#### Scenario: HTTPRoute is attached to the Gateway
- **WHEN** an `HTTPRoute` is applied with a `parentRef` pointing to the `Gateway`
- **THEN** the controller sets the `HTTPRoute` status condition `Accepted` to `True` and begins forwarding matching traffic

---

### Requirement: TLS termination with automated certificate management
The `Gateway` SHALL terminate TLS for all HTTPS listeners. Certificates MUST be automatically provisioned and renewed by cert-manager without manual intervention. cert-manager MUST use the Gateway API integration (`cert-manager.io/gateway-api` feature gate).

#### Scenario: Certificate is automatically provisioned on Gateway creation
- **WHEN** a `Gateway` HTTPS listener references a TLS secret and a cert-manager `Certificate` object targets that secret
- **THEN** cert-manager automatically requests and stores a valid TLS certificate in the referenced secret before the HTTPS listener becomes active

#### Scenario: Certificate is renewed before expiry
- **WHEN** a managed certificate is within 30 days of its expiry date
- **THEN** cert-manager automatically renews the certificate without downtime or traffic disruption

---

### Requirement: High availability
The Envoy Gateway controller and its managed Envoy proxy pods SHALL run with at least two replicas on the cluster's workload node pool to avoid a single point of failure.

#### Scenario: One Envoy proxy pod is unavailable
- **WHEN** one Envoy proxy pod managed by Envoy Gateway is restarted or evicted
- **THEN** traffic continues to be routed through the remaining proxy replica(s) without interruption
