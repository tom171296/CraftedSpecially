## 1. Bicep — Static Public IP

- [x] 1.1 Create `infra/modules/runtime_infrastructure/networking/` directory and add `public_ip.bicep` with a static Standard SKU public IP resource
- [x] 1.2 Output the IP address and resource ID from `public_ip.bicep`
- [x] 1.3 Add the `public_ip` module call to `runtime_infrastructure.bicep` and surface its outputs

## 2. Bicep — DNS Label on Public IP (replaces Azure DNS Zone)

> Decision: no custom domain — using Azure-provided DNS label on the static IP (`craftedspecially-pip.eastus.cloudapp.azure.com`).

- [x] 2.1 Add `dnsSettings.domainNameLabel` to `public_ip.bicep` using `toLower(publicIpName)` and output the FQDN
- [x] 2.2 Surface `gatewayFqdn` output from `runtime_infrastructure.bicep`

## 3. Kubernetes — Envoy Gateway Static IP Binding

- [x] 3.1 Update `infra/k8s/envoy-gateway/envoy-proxy.yaml` to set the `service.beta.kubernetes.io/azure-pip-name` and `azure-load-balancer-resource-group` annotations so Envoy Gateway's LoadBalancer Service claims the static IP

## 4. Kubernetes — TLS Certificate

- [x] 4.1 Set `dnsNames` in `infra/k8s/cert-manager/certificate.yaml` to `craftedspecially-pip.eastus.cloudapp.azure.com`
- [x] 4.2 Update `issuerRef.name` in `certificate.yaml` to `letsencrypt-prod`

## 5. Kubernetes — Gateway and HTTPRoute

- [x] 5.1 Update the `cert-manager.io/cluster-issuer` annotation in `infra/k8s/envoy-gateway/gateway.yaml` to `letsencrypt-prod`
- [x] 5.2 Update `hostnames` in `infra/k8s/crafted-specially/routes.yaml` to `craftedspecially-pip.eastus.cloudapp.azure.com`

## 6. Kubernetes — Production ClusterIssuer

- [x] 6.1 Fill in the `email` field in `infra/k8s/cert-manager/cluster-issuer-prod.yaml` with a valid operator email address

## 7. Verification

- [x] 7.1 Confirm `kubectl get svc -n envoy-gateway-system` shows EXTERNAL-IP equal to the static IP from Bicep output
- [x] 7.2 Confirm `kubectl get certificate craftedspecially-tls -n envoy-gateway-system` shows `READY=True`
- [x] 7.3 Open `https://craftedspecially-pip.eastus.cloudapp.azure.com/` in a browser and verify no TLS warning and valid response
