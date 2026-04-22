## Why

The HTTPRoute for `craftedspecially-api` currently has no hostname configured, making it unreachable via a stable public URL. For this demo project, the simplest path is to use the Azure-managed DNS label on a Public IP (`<label>.<region>.cloudapp.azure.com`) — no domain registrar, no DNS zone, no delegation required.

## What Changes

- Add a Bicep networking module that provisions a Static Public IP with a `domainNameLabel`, producing a stable FQDN managed entirely by Azure.
- Wire the networking module into `runtime_infrastructure.bicep` and expose the FQDN as a deployment output.
- Configure an `EnvoyProxy` resource so the Envoy Gateway LoadBalancer Service claims the static IP.
- Populate the `hostnames` field in `infra/k8s/routes/craftedspecially-api.yaml` with the Azure-managed FQDN.
- Populate `dnsNames` in `infra/k8s/cert-manager/certificate.yaml` with the same FQDN so Let's Encrypt can issue a TLS certificate.
- Add the ACME contact email to both ClusterIssuer manifests.

## Capabilities

### New Capabilities

- `public-dns-zone`: Provision a Static Public IP with an Azure-managed DNS label (`domainNameLabel`) via Bicep. No external DNS zone or registrar delegation needed.

### Modified Capabilities

- `httproute-hostname`: The existing HTTPRoute resource gains a concrete `hostnames` entry pointing to the Azure-managed FQDN.

## Impact

- **Bicep (infra/modules/)**: New `networking.bicep` module under `runtime_infrastructure`; wired into `runtime_infrastructure.bicep`.
- **Kubernetes manifests**: New `EnvoyProxy` resource; updated `gateway.yaml` (parametersRef); `craftedspecially-api.yaml` (HTTPRoute hostnames); `certificate.yaml` (dnsNames + ClusterIssuer email).
- **Dependencies**: Envoy Gateway must expose a LoadBalancer Service that claims the static IP via annotation — handled by the `EnvoyProxy` custom resource.
- **No external steps**: The `*.cloudapp.azure.com` zone is managed by Azure; no NS delegation or registrar changes are needed.
