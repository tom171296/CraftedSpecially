## 1. Gateway API CRDs

- [x] 1.1 Install the Kubernetes Gateway API standard CRDs (`gateway.networking.k8s.io`) on the cluster
- [ ] 1.2 Verify the CRDs are present: `GatewayClass`, `Gateway`, `HTTPRoute`

## 2. cert-manager Deployment

- [x] 2.1 Add cert-manager Helm chart values file (`infra/k8s/cert-manager/values.yaml`) with the `--feature-gates=ExperimentalGatewayAPISupport=true` flag enabled
- [ ] 2.2 Apply cert-manager Helm release to the cluster into the `cert-manager` namespace
- [x] 2.3 Create `ClusterIssuer` manifest for Let's Encrypt staging (`infra/k8s/cert-manager/cluster-issuer-staging.yaml`)
- [ ] 2.4 Verify cert-manager pods are running and the staging `ClusterIssuer` status is `Ready`

## 3. Envoy Gateway Deployment

- [x] 3.1 Add Envoy Gateway Helm chart values file (`infra/k8s/envoy-gateway/values.yaml`) with proxy replica count set to 2 and workload node pool affinity
- [ ] 3.2 Apply Envoy Gateway Helm release into the `envoy-gateway-system` namespace
- [x] 3.3 Apply `GatewayClass` manifest referencing the Envoy Gateway controller (`gateway.envoyproxy.io/gatewayclass-controller`)
- [ ] 3.4 Verify `GatewayClass` status condition `Accepted` is `True`

## 4. Gateway and TLS Configuration

- [x] 4.1 Create `Gateway` manifest with HTTP (port 80) and HTTPS (port 443) listeners (`infra/k8s/envoy-gateway/gateway.yaml`)
- [ ] 4.2 Verify the `Gateway` status condition `Programmed` is `True` and the `LoadBalancer` service has an external IP
- [x] 4.3 Create a cert-manager `Certificate` object targeting the `Gateway`'s TLS secret using the staging `ClusterIssuer`
- [ ] 4.4 Verify the certificate is issued and the HTTPS listener is active (accept staging CA warning)
- [x] 4.5 Create `ClusterIssuer` manifest for Let's Encrypt production (`infra/k8s/cert-manager/cluster-issuer-prod.yaml`) and switch the `Certificate` to it
- [ ] 4.6 Verify a trusted TLS certificate is served on the HTTPS listener

## 5. Bicep Infrastructure Updates

- [ ] 5.1 Add an output to `infra/modules/runtime_infrastructure/hosting/AKS.bicep` if a static public IP is required (add a `publicIPAddress` resource)
- [ ] 5.2 Wire new outputs through `infra/modules/runtime_infrastructure/runtime_infrastructure.bicep` to `infra/CraftedSpecially.bicep` as needed

## 6. HTTPRoute Configuration

- [x] 6.1 Define initial `HTTPRoute` object(s) with host/path rules for each application service requiring external access
- [ ] 6.2 Verify each `HTTPRoute` status condition `Accepted` is `True`
- [ ] 6.3 Verify host-based and path-prefix routing correctly reaches the respective backend services
- [ ] 6.4 Confirm a request to an undefined path/host returns HTTP 404

## 7. Validation and Documentation

- [ ] 7.1 Confirm the gateway continues serving traffic when one Envoy proxy pod is restarted (HA check)
- [x] 7.2 Document the gateway setup, DNS configuration steps, and how to add new `HTTPRoute` resources in the project runbook
