## 1. Bicep – Networking Module

- [x] 1.1 Create `infra/modules/runtime_infrastructure/networking/networking.bicep` with `domainNameLabel` and `location` parameters
- [x] 1.2 Add an Azure Static Public IP resource (Standard SKU, Static allocation) with the `domainNameLabel` property set, and emit the IP address and FQDN (`properties.dnsSettings.fqdn`) as outputs
- [x] 1.3 Wire the `networking` module into `runtime_infrastructure.bicep`, passing `projectLocation` and a `domainNameLabel` parameter, and propagating the IP address and FQDN as outputs

## 2. Kubernetes – Gateway Static IP

- [x] 2.1 Create `infra/k8s/envoy-gateway/envoy-proxy.yaml` — an `EnvoyProxy` resource in namespace `envoy-gateway-system` that sets the `service.beta.kubernetes.io/azure-load-balancer-ipv4` annotation to the static IP (use a `# TODO` placeholder for the IP value, filled in after Bicep deploy)
- [x] 2.2 Update `infra/k8s/envoy-gateway/gateway.yaml` to add `spec.infrastructure.parametersRef` pointing to the `EnvoyProxy` resource
- [x] 2.3 Update the `envoy-gateway` ArgoCD Application in `infra/k8s/argocd/apps/envoy-gateway.yaml` to include `envoy-proxy.yaml` in its `directory.include` list alongside `gatewayclass.yaml` and `gateway.yaml`

## 3. Kubernetes – HTTPRoute Hostname

- [x] 3.1 Replace the empty `hostnames` field in `infra/k8s/routes/craftedspecially-api.yaml` with the Azure-managed FQDN (use a `# TODO` placeholder of the form `<domainNameLabel>.<region>.cloudapp.azure.com`, filled in after Bicep deploy)
- [x] 3.2 Confirm the backend `port` in the HTTPRoute matches the actual `craftedspecially-api` Service port (currently set to 8080 — verify against Service manifest)

## 4. Kubernetes – cert-manager TLS

- [x] 4.1 Replace the empty `dnsNames` entry in `infra/k8s/cert-manager/certificate.yaml` with the same Azure-managed FQDN placeholder used in task 3.1
- [x] 4.2 Add a `# TODO` placeholder email to `spec.acme.email` in `infra/k8s/cert-manager/cluster-issuer-staging.yaml`
- [x] 4.3 Add the same `# TODO` placeholder email to `infra/k8s/cert-manager/cluster-issuer-prod.yaml`

## 5. Validation (after Bicep deploy)

- [ ] 5.1 After Bicep deployment, retrieve the FQDN from output (`az deployment group show ... --query properties.outputs.fqdn.value`) and fill in the `# TODO` placeholders in tasks 2.1, 3.1, and 4.1
- [ ] 5.2 Confirm the FQDN resolves to the static IP: `dig A <fqdn>`
- [ ] 5.3 Confirm the cert-manager Certificate resource reaches `Ready=True` in the staging environment
- [ ] 5.4 Confirm HTTPS traffic reaches the backend: `curl -k https://<fqdn>` (accept staging cert)
- [ ] 5.5 Switch the Certificate `issuerRef` to `letsencrypt-prod` and verify a browser-trusted certificate is issued
