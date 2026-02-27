## ADDED Requirements

### Requirement: ArgoCD accessible at /argocd path prefix
The Gateway SHALL route all requests with path prefix `/argocd` to the `argocd-server` Service in the `argocd` namespace. ArgoCD SHALL be configured with `server.rootpath: /argocd` so that internal links and redirects are correct.

#### Scenario: ArgoCD UI loads at path prefix
- **WHEN** an HTTP request is made to `https://<gateway-fqdn>/argocd`
- **THEN** the response is a redirect or the ArgoCD UI HTML with status 200 or 302

#### Scenario: ArgoCD internal links use correct prefix
- **WHEN** the ArgoCD UI is loaded at `/argocd`
- **THEN** all navigation links and API calls reference `/argocd/...` paths, not bare `/` paths

#### Scenario: Requests outside /argocd do not reach ArgoCD
- **WHEN** an HTTP request is made to `https://<gateway-fqdn>/api/some-path`
- **THEN** the request is NOT forwarded to the `argocd-server` Service

### Requirement: CraftedSpecially API accessible at /api path prefix
The Gateway SHALL route all requests with path prefix `/api` to the `crafted-specially-api` Service in the `crafted-specially` namespace.

#### Scenario: API request routed correctly
- **WHEN** an HTTP request is made to `https://<gateway-fqdn>/api/health`
- **THEN** the response comes from the `crafted-specially-api` Service with status 200

#### Scenario: Requests outside /api do not reach the API
- **WHEN** an HTTP request is made to `https://<gateway-fqdn>/argocd/some-path`
- **THEN** the request is NOT forwarded to the `crafted-specially-api` Service

### Requirement: Both routes use the same Gateway listener and hostname
The ArgoCD HTTPRoute and the CraftedSpecially API HTTPRoute SHALL both reference the `craftedspecially-gateway` HTTPS listener and use the FQDN of the `CraftedSpecially-pip` public IP as their hostname. No hard-coded region strings (e.g., `eastus`) SHALL appear in the route manifests.

#### Scenario: Single public IP serves both services
- **WHEN** DNS for the gateway FQDN resolves
- **THEN** the resolved IP address is the same for both `<fqdn>/argocd` and `<fqdn>/api` requests

#### Scenario: No stale region string in manifests
- **WHEN** the HTTPRoute manifests in `infra/k8s/argocd/routes.yaml` and `infra/k8s/crafted-specially/routes.yaml` are inspected
- **THEN** neither file contains the string `eastus`

### Requirement: TLS certificate covers the shared hostname
A cert-manager `Certificate` resource SHALL exist for the gateway FQDN and SHALL be referenced by the Gateway's HTTPS listener. The certificate SHALL be valid and not expired.

#### Scenario: Certificate issued for gateway FQDN
- **WHEN** the cert-manager Certificate resource is inspected
- **THEN** its `dnsNames` list includes the `CraftedSpecially-pip` FQDN

#### Scenario: HTTPS listener uses the certificate
- **WHEN** a TLS handshake is initiated to `https://<gateway-fqdn>`
- **THEN** the server presents a valid certificate for that hostname signed by Let's Encrypt
