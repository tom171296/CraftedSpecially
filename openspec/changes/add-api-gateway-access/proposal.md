## Why

The AKS cluster currently has no external ingress layer, meaning applications running on the cluster have no standardised way to be reached from outside. Adding an API gateway provides a single, controlled entry point for external traffic, enabling routing, TLS termination, and future cross-cutting concerns such as authentication and rate limiting.

## What Changes

- Deploy an API gateway as a Kubernetes-native ingress layer in front of the AKS cluster
- Configure the gateway to route HTTP/HTTPS traffic to application workloads
- Update the AKS Bicep module to enable any required Azure-side networking (public IP, load balancer integration)
- Provision the gateway via Helm/Kubernetes manifests alongside the existing infrastructure

## Capabilities

### New Capabilities
- `api-gateway`: CNCF-compliant API gateway deployed on the AKS cluster, providing external HTTP/HTTPS ingress, TLS termination, and path/host-based routing to application services

### Modified Capabilities

## Impact

- `infra/modules/runtime_infrastructure/hosting/AKS.bicep`: may need additional networking parameters or outputs (e.g. public IP prefix, ingress subnet)
- `infra/modules/runtime_infrastructure/runtime_infrastructure.bicep`: wire through any new AKS networking outputs
- New Helm/Kubernetes manifest files for the gateway controller and gateway configuration
- No breaking changes to existing application workloads; existing services remain reachable on their internal cluster DNS
