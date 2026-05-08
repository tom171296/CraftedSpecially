## 1. Fix Envoy Gateway ArgoCD Application

- [ ] 1.1 Commit `infra/k8s/argocd/apps/envoy-gateway.yaml` with the `oci://` prefix fix to `main`
- [ ] 1.2 Verify ArgoCD picks up the change and the `envoy-gateway` Application reaches `Synced / Healthy`
- [ ] 1.3 Confirm Envoy Gateway controller pods are `Running` in `envoy-gateway-system`

## 2. Verify Public IP Binding

- [ ] 2.1 Run `kubectl -n envoy-gateway-system get svc` and confirm `EXTERNAL-IP` matches the address of `craftedspecially-pip.eastus.cloudapp.azure.com`
- [ ] 2.2 If the IP is not bound, run `kubectl -n envoy-gateway-system describe svc <envoy-svc-name>` and check the Events for errors from the Azure cloud controller
- [ ] 2.3 If RBAC errors appear, verify the AKS system-assigned identity has `Network Contributor` on the `CraftedSpecially` resource group in the Azure portal

## 3. Verify TLS Certificate

- [ ] 3.1 Run `kubectl -n envoy-gateway-system get certificate craftedspecially-tls` and wait for `Ready=True`
- [ ] 3.2 If the certificate is stuck, run `kubectl -n envoy-gateway-system describe certificaterequest` to check the ACME challenge status
- [ ] 3.3 If Let's Encrypt rate-limited, temporarily patch the `ClusterIssuer` ref in `certificate.yaml` to `letsencrypt-staging` to test the flow, then revert to prod

## 4. Smoke Test End-to-End Connectivity

- [ ] 4.1 Run `curl -I https://craftedspecially-pip.eastus.cloudapp.azure.com/argocd` and confirm `200 OK`
- [ ] 4.2 Run `curl -I https://craftedspecially-pip.eastus.cloudapp.azure.com/api` and confirm the API is reachable (no gateway-level 5xx)
- [ ] 4.3 Open the Argo CD UI in a browser and confirm the login page loads correctly
