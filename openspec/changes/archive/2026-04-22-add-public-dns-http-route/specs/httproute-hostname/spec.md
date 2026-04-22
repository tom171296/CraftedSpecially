## ADDED Requirements

### Requirement: HTTPRoute hostnames field populated with the public FQDN
The `craftedspecially-api` HTTPRoute SHALL specify the application's public FQDN in its `hostnames` field so that the Envoy Gateway only routes requests matching that domain.

#### Scenario: Traffic routed for matching hostname
- **WHEN** an HTTPS request arrives at the Gateway with a `Host` header matching the configured FQDN
- **THEN** the Gateway routes the request to the `craftedspecially-api` backend service on port 8080

#### Scenario: Traffic rejected for non-matching hostname
- **WHEN** an HTTPS request arrives at the Gateway with a `Host` header that does not match the configured FQDN
- **THEN** the Gateway returns a 404 or 421 response

### Requirement: cert-manager Certificate dnsNames and ClusterIssuer email populated
The cert-manager `Certificate` resource SHALL list the application FQDN in `dnsNames` and both ClusterIssuer manifests SHALL include a valid ACME contact email so that Let's Encrypt can issue a TLS certificate for the domain.

#### Scenario: Certificate issued for the public domain
- **WHEN** cert-manager processes the `Certificate` resource with the FQDN in `dnsNames`
- **THEN** Let's Encrypt completes the HTTP-01 ACME challenge and issues a certificate for that domain

#### Scenario: Certificate renewed before expiry
- **WHEN** the certificate is within 30 days of expiry
- **THEN** cert-manager automatically renews it using the same ClusterIssuer

#### Scenario: HTTPS enforced by Gateway TLS listener
- **WHEN** the Gateway is configured with a TLS listener referencing the `craftedspecially-tls` Secret
- **THEN** the HTTPRoute only accepts traffic on the HTTPS section and the TLS certificate is served to clients
