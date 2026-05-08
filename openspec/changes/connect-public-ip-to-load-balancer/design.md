## Context

CraftedSpecially uses Envoy Gateway as the ingress layer, fronted by a static Azure Public IP (`CraftedSpecially-pip` in the `CraftedSpecially` resource group, `eastus`). The public IP is provisioned by Bicep. Kubernetes manifests wire it to the Envoy LoadBalancer Service via two annotations on the `EnvoyProxy` resource:

```yaml
service.beta.kubernetes.io/azure-pip-name: "CraftedSpecially-pip"
service.beta.kubernetes.io/azure-load-balancer-resource-group: "CraftedSpecially"
```

The AKS cloud controller manager reads these annotations and associates the pre-provisioned IP with the LoadBalancer Service when it is created. However, Envoy Gateway has never been deployed because the ArgoCD Application manifest has a malformed Helm chart source URL — `docker.io/envoyproxy` instead of `oci://docker.io/envoyproxy`. ArgoCD cannot resolve a plain hostname as an OCI registry, so the sync fails silently and the Envoy Gateway Helm release is never installed.

Without Envoy Gateway, there is no LoadBalancer Service, no Envoy proxy pods, and nothing to attach the public IP to.

## Goals / Non-Goals

**Goals:**
- Fix the ArgoCD Application manifest so Envoy Gateway deploys successfully
- Ensure the LoadBalancer Service receives the static public IP via the existing EnvoyProxy annotations
- Verify RBAC: AKS managed identity must have Network Contributor on the resource group containing the public IP
- Argo CD UI reachable at `https://craftedspecially-pip.eastus.cloudapp.azure.com/argocd`
- CraftedSpecially API reachable at `https://craftedspecially-pip.eastus.cloudapp.azure.com/api`

**Non-Goals:**
- Changing the networking topology (gateway, listeners, routes stay the same)
- Adding HTTP→HTTPS redirect (out of scope for this change)
- Migrating from static IP to dynamic IP

## Decisions

### Fix the OCI repoURL, not the ArgoCD version or chart source

The Envoy Gateway chart is published as an OCI artifact at `oci://docker.io/envoyproxy/gateway-helm`. ArgoCD requires the `oci://` scheme prefix to distinguish OCI registries from standard Helm HTTP repositories. The fix is a one-character-prefix change to the manifest — no version bump or chart migration needed.

**Alternative considered:** switching to the `https://gateway.envoyproxy.io/helm` HTTP repository. Rejected because the OCI source is the canonical distribution and avoids adding a new Helm repo.

### Use EnvoyProxy service annotations for IP binding (existing approach)

The `azure-pip-name` + `azure-load-balancer-resource-group` annotation pattern is the correct AKS mechanism for pre-provisioned static IPs. It is already in place in `envoy-proxy.yaml`. No additional configuration is needed once the Service exists.

**Alternative considered:** using `spec.loadBalancerIP` on the Service directly. This field is deprecated in Kubernetes 1.24+ and ignored by the Azure cloud provider in favour of the annotation-based approach.

### AKS identity for cloud controller operations

The AKS cluster uses a system-assigned managed identity. The Bicep grants it `Network Contributor` at the `CraftedSpecially` resource group scope. This is the identity the cloud controller manager uses to manage load balancers and associate public IPs. No additional role assignment is needed.

## Risks / Trade-offs

- **Let's Encrypt rate limits** → The cert-manager `ClusterIssuer` targets `letsencrypt-prod`. If the domain has already had failed issuance attempts, rate limits may delay the certificate. Mitigation: switch to `letsencrypt-staging` issuer temporarily to test the ACME challenge flow before retrying prod.
- **Gateway not reconciling EnvoyProxy** → If the `EnvoyProxy` CRD is applied before Envoy Gateway's CRD is installed (ordering issue), the resource will be ignored. ArgoCD sync-wave `-1` on the envoy-gateway Application ensures the Helm release (which installs CRDs) lands before the raw manifests. Verify this ordering holds after the fix.
- **Public IP region constraint** → Azure requires the public IP and the cluster's load balancer to be in the same region (`eastus`). The Bicep and all manifests are aligned on `eastus`. If the Bicep `projectLocation` parameter is overridden at deploy time to a different region, IP association will silently fail.

## Migration Plan

1. Commit the `oci://` prefix fix to `infra/k8s/argocd/apps/envoy-gateway.yaml`
2. Push to `main` — ArgoCD auto-sync picks it up within ~3 minutes
3. Monitor the `envoy-gateway` ArgoCD Application until `Synced / Healthy`
4. Verify the LoadBalancer Service has the correct external IP: `kubectl -n envoy-gateway-system get svc`
5. Confirm cert-manager issues the certificate: `kubectl -n envoy-gateway-system get certificate craftedspecially-tls`
6. Smoke-test: `curl -I https://craftedspecially-pip.eastus.cloudapp.azure.com/argocd`

**Rollback:** revert the commit — ArgoCD will uninstall Envoy Gateway on the next sync (prune is enabled). The public IP returns to unattached state.
