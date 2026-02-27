## ADDED Requirements

### Requirement: Certificate uses custom domain FQDN
The cert-manager `Certificate` resource at `infra/k8s/cert-manager/certificate.yaml` SHALL have its `dnsNames` set to the custom domain (e.g., `api.craftedspecially.example.com`) replacing the existing placeholder.

#### Scenario: cert-manager issues certificate for custom domain
- **WHEN** the updated Certificate manifest is applied and DNS resolves the domain to the static IP
- **THEN** `kubectl get certificate craftedspecially-tls -n envoy-gateway-system` shows `READY=True`

#### Scenario: Certificate auto-renews before expiry
- **WHEN** the certificate is within 30 days of expiry
- **THEN** cert-manager automatically renews it using the Let's Encrypt HTTP-01 challenge via the Envoy Gateway

### Requirement: HTTPRoute hostname updated to custom domain
The `HTTPRoute` resource at `infra/k8s/crafted-specially/routes.yaml` SHALL set `hostnames` to the same custom domain FQDN used in the Certificate.

#### Scenario: HTTPS traffic reaches the application on the custom domain
- **WHEN** a client sends an HTTPS request to `https://<custom-domain>/`
- **THEN** the request is routed to the `crafted-specially-api` service and returns a valid response

#### Scenario: HTTPRoute rejects traffic for unknown hostnames
- **WHEN** a request arrives with a hostname not matching the configured custom domain
- **THEN** Envoy Gateway returns 404 or drops the connection

### Requirement: Production Let's Encrypt ClusterIssuer activated
The Gateway annotation in `infra/k8s/envoy-gateway/gateway.yaml` and the Certificate `issuerRef` SHALL reference `letsencrypt-prod` instead of `letsencrypt-staging`. The `letsencrypt-prod` ClusterIssuer at `infra/k8s/cert-manager/cluster-issuer-prod.yaml` SHALL have the operator's email address filled in.

#### Scenario: Browser trusts the TLS certificate
- **WHEN** a user opens `https://<custom-domain>/` in a browser
- **THEN** the browser shows a valid, trusted TLS certificate (no security warning)

#### Scenario: ClusterIssuer email is not blank
- **WHEN** the production ClusterIssuer manifest is applied
- **THEN** the `email` field contains a valid address (non-empty string)
