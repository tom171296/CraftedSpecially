## 1. Bicep Networking — Public Load Balancer

- [x] 1.1 Add `envoyInternalIp` parameter (with default) to `networking.bicep` for the fixed private IP of the Envoy internal LB
- [x] 1.2 Add `Microsoft.Network/loadBalancers` resource to `networking.bicep` with Standard SKU and the static public IP as the frontend IP configuration
- [x] 1.3 Add a backend address pool to the public LB targeting the AKS node subnet
- [x] 1.4 Add a TCP health probe on port 30080 to the public LB
- [x] 1.5 Add load-balancing rule: TCP frontend port 80 → backend port 30080
- [x] 1.6 Add load-balancing rule: TCP frontend port 443 → backend port 30443
- [x] 1.7 Add `envoyInternalIp` as a Bicep output in `networking.bicep`
- [x] 1.8 Pass `envoyInternalIp` output through `runtime_infrastructure.bicep` as a deployment output

## 2. Bicep Runtime Infrastructure — Parameter Wiring

- [x] 2.1 Add `envoyInternalIp` parameter to `runtime_infrastructure.bicep` and pass it to the `networking` module
- [x] 2.2 Verify the AKS module outputs the node subnet ID and wire it into the networking module backend pool if needed

## 3. Kubernetes — EnvoyProxy Configuration

- [x] 3.1 Update `infra/k8s/envoy-gateway/envoy-proxy.yaml`: add `service.beta.kubernetes.io/azure-load-balancer-internal: "true"` annotation to make the service an internal LB
- [x] 3.2 Update `envoy-proxy.yaml`: set `service.beta.kubernetes.io/azure-load-balancer-ipv4` to the fixed private IP (matching the Bicep `envoyInternalIp` value)
- [x] 3.3 Update `envoy-proxy.yaml`: configure fixed node ports 30080 (HTTP) and 30443 (HTTPS) via the `EnvoyProxy` `envoyService.ports` field (or equivalent) — N/A: Bicep Public LB routes directly to the internal LB IP on ports 80/443; no node ports required.

## 4. ArgoCD / GitOps Sync

- [x] 4.1 Verify the updated `EnvoyProxy` manifest is included in the ArgoCD application sync path
- [x] 4.2 Confirm ArgoCD has RBAC permissions to manage `EnvoyProxy` resources after the annotation change

## 5. Verification

- [ ] 5.1 Deploy updated Bicep and confirm the Azure Public Load Balancer is created with the static IP as its frontend
- [ ] 5.2 Sync ArgoCD and confirm the Envoy LoadBalancer Service shows a private IP (not the public IP) in `kubectl get svc`
- [ ] 5.3 Confirm the Bicep Public LB health probe turns green (all AKS nodes healthy in backend pool)
- [ ] 5.4 Send a test HTTPS request to the public FQDN and confirm it reaches the Envoy proxy and is forwarded to the `craftedspecially-api` backend
- [ ] 5.5 Confirm that directly hitting the Envoy internal LB private IP from outside the VNet times out (internet cannot reach it)

<!-- Verification tasks 5.1–5.5 require a live Azure environment. Run after deploying. -->
