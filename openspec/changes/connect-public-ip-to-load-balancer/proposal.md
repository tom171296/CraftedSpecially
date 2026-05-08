## Why

The static public IP (`craftedspecially-pip.eastus.cloudapp.azure.com`) provisioned in Azure is not attached to the Envoy Gateway LoadBalancer Service, making the Argo CD UI and CraftedSpecially API unreachable from the internet. The root cause is a missing `oci://` prefix in the committed ArgoCD Application manifest for Envoy Gateway, which prevents ArgoCD from pulling the Helm chart and therefore prevents the gateway — and its LoadBalancer Service — from ever being created.

## What Changes

- Fix the `repoURL` in `infra/k8s/argocd/apps/envoy-gateway.yaml` to use the `oci://` scheme so ArgoCD can pull the Envoy Gateway Helm chart from the OCI registry
- Verify the `EnvoyProxy` service annotations (`azure-pip-name`, `azure-load-balancer-resource-group`) are correctly wiring the static public IP to the LoadBalancer Service
- Verify the AKS managed identity has the `Network Contributor` role on the resource group containing the public IP, so the cloud controller manager can claim it

## Capabilities

### New Capabilities

- `public-gateway-access`: Envoy Gateway is deployed and reachable via the static public IP, with HTTPS terminated at the gateway. Argo CD UI (`/argocd`) and the CraftedSpecially API (`/api`) are routable over the internet through the gateway.

### Modified Capabilities

## Impact

- `infra/k8s/argocd/apps/envoy-gateway.yaml` — one-line fix to repoURL
- ArgoCD syncs the corrected manifest and deploys Envoy Gateway via Helm
- Azure cloud controller manager associates `CraftedSpecially-pip` with the LoadBalancer Service created by Envoy Gateway
- cert-manager issues a Let's Encrypt certificate for `craftedspecially-pip.eastus.cloudapp.azure.com`
- HTTPRoutes for Argo CD and the API become active once the gateway is up and the certificate is ready
