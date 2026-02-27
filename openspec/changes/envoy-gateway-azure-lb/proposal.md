## Why

Envoy Gateway provisions a Kubernetes LoadBalancer Service that needs to be bound to the pre-provisioned Azure static public IP so that DNS is stable across re-deployments. Currently the AKS cluster identity lacks the RBAC permissions to claim that IP from the main resource group, the HTTPRoute hostnames are inconsistent with the actual IP FQDN, and there is no cert-manager certificate covering all exposed hostnames — meaning neither ArgoCD nor the CraftedSpecially API can be reached reliably from the internet.

## What Changes

- Grant the AKS cluster's managed identity `Network Contributor` on the `CraftedSpecially` resource group so AKS can bind the pre-provisioned public IP to the Envoy Gateway LoadBalancer Service.
- Fix the HTTPRoute hostname for ArgoCD to use the actual public IP FQDN (`craftedspecially-pip.<region>.cloudapp.azure.com`) with a dedicated path prefix, replacing the stale placeholder `argocd.eastus.cloudapp.azure.com`.
- Consolidate both ArgoCD and the CraftedSpecially API under the same Gateway listener and public IP, differentiated by path-based routing (`/argocd/*` → ArgoCD, `/api/*` → CraftedSpecially API).
- Issue a single cert-manager TLS certificate for the shared hostname covering both routes.
- Remove the region hard-coding (`eastus`) from all HTTPRoute manifests and align with the Bicep-deployed region (`canadacentral`).

## Capabilities

### New Capabilities

- `aks-lb-public-ip-rbac`: Grant AKS managed identity Network Contributor on the resource group so the Envoy Gateway LoadBalancer Service can claim the pre-provisioned static public IP.
- `gateway-path-routing`: Define path-based HTTPRoutes that expose ArgoCD at `/argocd` and the CraftedSpecially API at `/api` through a single Gateway listener and public IP.

### Modified Capabilities

(none)

## Impact

- **Bicep** (`infra/modules/runtime_infrastructure/hosting/AKS.bicep`): add a role assignment for the AKS cluster identity.
- **K8s manifests** (`infra/k8s/argocd/routes.yaml`, `infra/k8s/crafted-specially/routes.yaml`): update hostnames and path rules.
- **cert-manager** (`infra/k8s/cert-manager/certificate.yaml`): ensure the certificate covers the shared FQDN.
- **ArgoCD** (`infra/k8s/argocd/values.yaml`): verify `server.rootpath` is set so the UI works under a path prefix.
- No application code changes required.
