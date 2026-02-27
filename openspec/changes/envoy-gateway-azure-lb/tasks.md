## 1. Azure RBAC — AKS identity permissions

- [x] 1.1 Add a `roleAssignment` resource to `infra/modules/runtime_infrastructure/hosting/AKS.bicep` that grants the AKS cluster's system-assigned managed identity the `Network Contributor` role (ID `4d97b98b-1d4f-4787-a291-c67834d212e7`) scoped to the resource group
- [x] 1.2 Re-deploy the `deployRuntimeInfrastructure` Bicep module and verify the role assignment appears in the Azure portal under the `CraftedSpecially` RG → Access control (IAM)

## 2. Retrieve and record gateway FQDN

- [x] 2.1 Run `az deployment group show --name deployPublicIp --resource-group CraftedSpecially --query properties.outputs.fqdn.value -o tsv` to get the actual FQDN of the static IP (format: `craftedspecially-pip.<region>.cloudapp.azure.com`)
- [x] 2.2 Note the FQDN — it will replace all placeholder hostnames in the route manifests

## 3. ArgoCD Helm values — root path

- [x] 3.1 Add `server.rootpath: /argocd` to `infra/k8s/argocd/values.yaml` under the `server:` key
- [x] 3.2 Add `configs.params."server.basehref": /argocd` to the same file so the UI assets load from the correct base path

## 4. Update ArgoCD HTTPRoute

- [x] 4.1 In `infra/k8s/argocd/routes.yaml`, replace the hostname `argocd.eastus.cloudapp.azure.com` with the FQDN retrieved in step 2.1
- [x] 4.2 Change the path match from `PathPrefix: /` to `PathPrefix: /argocd` so the route does not capture all traffic

## 5. Update CraftedSpecially API HTTPRoute

- [x] 5.1 In `infra/k8s/crafted-specially/routes.yaml`, replace the hostname `craftedspecially-pip.eastus.cloudapp.azure.com` with the FQDN retrieved in step 2.1
- [x] 5.2 Change the path match from `PathPrefix: /` to `PathPrefix: /api` so the route only captures API traffic

## 6. cert-manager certificate

- [x] 6.1 In `infra/k8s/cert-manager/certificate.yaml`, ensure `spec.dnsNames` includes the FQDN from step 2.1 (add or update the entry)
- [x] 6.2 Verify `spec.secretName` matches the `certificateRefs[].name` value in the Gateway HTTPS listener (`craftedspecially-tls`)

## 7. Sync and verify

- [ ] 7.1 Sync the ArgoCD Application for `argocd-routes` and verify no `HTTPRoute` errors in the Gateway status
- [ ] 7.2 Sync the ArgoCD Application for `crafted-specially` and verify the route is accepted
- [ ] 7.3 Wait for the cert-manager Certificate to reach `Ready: True` (`kubectl get certificate -n envoy-gateway-system`)
- [ ] 7.4 Confirm the Envoy Gateway LoadBalancer Service has the correct external IP (`kubectl get svc -n envoy-gateway-system`)
- [ ] 7.5 Test ArgoCD: `curl -L https://<fqdn>/argocd` returns the ArgoCD login page
- [ ] 7.6 Test the API: `curl https://<fqdn>/api/health` returns HTTP 200
