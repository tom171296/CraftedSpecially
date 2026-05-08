## ADDED Requirements

### Requirement: Envoy Gateway deploys from ArgoCD
The ArgoCD Application for Envoy Gateway SHALL use a valid OCI registry URL (`oci://docker.io/envoyproxy`) so that the Helm chart can be pulled and the release installed on the cluster.

#### Scenario: ArgoCD syncs Envoy Gateway successfully
- **WHEN** ArgoCD reconciles the `envoy-gateway` Application from `main`
- **THEN** the Application reaches `Synced` and `Healthy` status within 5 minutes

#### Scenario: Envoy Gateway pods are running
- **WHEN** the `envoy-gateway` Application is synced
- **THEN** Envoy Gateway controller pods are `Running` in the `envoy-gateway-system` namespace

### Requirement: Static public IP is bound to the LoadBalancer Service
The Envoy Gateway LoadBalancer Service SHALL be associated with the pre-provisioned Azure Public IP (`CraftedSpecially-pip`) via the `azure-pip-name` and `azure-load-balancer-resource-group` service annotations.

#### Scenario: LoadBalancer Service receives the static IP
- **WHEN** the Envoy Gateway LoadBalancer Service is created with the correct annotations
- **THEN** the Service's `EXTERNAL-IP` field shows the IP address of `craftedspecially-pip.eastus.cloudapp.azure.com` within 3 minutes

#### Scenario: Annotations are present on the Service
- **WHEN** the EnvoyProxy resource is applied with `envoyService.annotations`
- **THEN** the generated LoadBalancer Service carries both `azure-pip-name: CraftedSpecially-pip` and `azure-load-balancer-resource-group: CraftedSpecially`

### Requirement: TLS certificate is issued for the public hostname
cert-manager SHALL issue a valid TLS certificate for `craftedspecially-pip.eastus.cloudapp.azure.com` using the `letsencrypt-prod` ClusterIssuer, stored as the `craftedspecially-tls` Secret in `envoy-gateway-system`.

#### Scenario: Certificate reaches Ready state
- **WHEN** the public IP is bound and DNS resolves to the correct address
- **THEN** the `craftedspecially-tls` Certificate resource reaches `Ready=True` within 10 minutes

### Requirement: Argo CD UI is reachable over HTTPS
The Argo CD server SHALL be accessible at `https://craftedspecially-pip.eastus.cloudapp.azure.com/argocd` via the Envoy Gateway HTTPRoute.

#### Scenario: Argo CD UI returns HTTP 200
- **WHEN** an HTTPS GET request is made to `https://craftedspecially-pip.eastus.cloudapp.azure.com/argocd`
- **THEN** the response status is `200 OK` and the Argo CD login page is served

### Requirement: CraftedSpecially API is reachable over HTTPS
The CraftedSpecially API SHALL be accessible at `https://craftedspecially-pip.eastus.cloudapp.azure.com/api` via the Envoy Gateway HTTPRoute.

#### Scenario: API health check returns a successful response
- **WHEN** an HTTPS GET request is made to `https://craftedspecially-pip.eastus.cloudapp.azure.com/api`
- **THEN** the response status indicates the API is reachable (2xx or 404 for unknown paths, not a gateway error)
