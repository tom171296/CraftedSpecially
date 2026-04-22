## Why

The Envoy Gateway proxy is currently configured to receive a static public IP directly on its LoadBalancer Kubernetes Service, which exposes the proxy endpoint directly to the internet. Moving to an Azure Internal Load Balancer for the Envoy service and fronting it with a Bicep-managed Azure Public Load Balancer provides a clear separation between the public entry point and the cluster-internal load balancing layer, enabling better security isolation and giving explicit control over which resources have public exposure.

## What Changes

- The `EnvoyProxy` custom resource is updated to annotate the Envoy service as an **Azure Internal Load Balancer** (private IP within the AKS VNet subnet) instead of a public-facing load balancer.
- The `networking.bicep` module is extended to provision a **Standard Azure Public Load Balancer** with the existing static public IP as its frontend, and load-balancing rules that forward TCP 80 and 443 traffic to the AKS node pool backend.
- The `service.beta.kubernetes.io/azure-load-balancer-ipv4` annotation on the `EnvoyProxy` is changed from a public IP to a **fixed private IP** from the AKS subnet, ensuring a stable internal endpoint.
- The Bicep networking module outputs the private IP (internal LB) in addition to the public IP so both values are available for downstream configuration.

## Capabilities

### New Capabilities

- `envoy-internal-load-balancer`: Configures the Envoy proxy Kubernetes service as an Azure Internal Load Balancer with a stable private IP, deployed via the `EnvoyProxy` custom resource annotations. Includes the Bicep Public Load Balancer resource that bridges the static public IP to the internal LB backend.

### Modified Capabilities

- `public-dns-zone`: The static public IP is no longer assigned directly to the Envoy Gateway LoadBalancer Service; it is instead the frontend IP of the Bicep-managed Azure Public Load Balancer that routes internet traffic into the cluster.

## Impact

- `infra/k8s/envoy-gateway/envoy-proxy.yaml` — service type annotation changes from public IP to internal LB + private IP
- `infra/modules/runtime_infrastructure/networking/networking.bicep` — new Azure Public Load Balancer resource with frontend IP config, backend pool referencing AKS node pool, and load-balancing rules for ports 80 and 443
- `infra/modules/runtime_infrastructure/runtime_infrastructure.bicep` — may need additional parameters passed to the networking module (e.g., AKS node pool subnet ID for the backend pool)
- `openspec/specs/public-dns-zone/spec.md` — requirement for "static public IP assigned to Envoy Gateway LoadBalancer via EnvoyProxy" changes: the IP is now on the Bicep Public LB, not the K8s service annotation
