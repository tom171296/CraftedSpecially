# Provenance and attestation

This document describes the theory and implementation in crafted specially of provenance
and attestation. 

## Prerequisites

az login

az acr login --name techorama

## Provenance

## Demo's

Push to the registry:

```bash
docker push techorama.azurecr.io/crafted-specially:latest
```

Sign image:

```bash
cosign sign techorama.azurecr.io/crafted-specially@sha256:255e4606829ed4b7c29d8e99c7916d5d411aab38555ad804c42ba1be157e3d73
```

Cosign certificate:

```bash
cosign download signature techorama.azurecr.io/crafted-specially@sha256:255e4606829ed4b7c29d8e99c7916d5d411aab38555ad804c42ba1be157e3d73
```

Get Rekor metadata:

```bash
./scripts/rekor-issuer.sh "https://rekor.sigstore.dev/api/v1/log/entries?logIndex=3537931593"
```

Verify image:

```bash
cosign verify techorama.azurecr.io/crafted-specially@sha256:255e4606829ed4b7c29d8e99c7916d5d411aab38555ad804c42ba1be157e3d73 --certificate-identity tom171296@users.noreply.github.com --certificate-oidc-issuer https://github.com/login/oauth
```

---

DEMO provenance and attestation with github actions.

---

ORAS

```bash
oras push techorama.azurecr.io/oras-demo/artifact:demo --artifact-type readme/example ./oras-example.md:application/markdown
```

```bash
cosign sign techorama.azurecr.io/oras-demo/artifact@sha256:5e5d13e7c4e83c6970eb4ad767e679fd505abb0ea6945a94125f54ed113d4810
```

---

Verify slsa

```bash
gh attestation verify oci://techorama.azurecr.io/crafted-specially@sha256:9473fc03c7301d5deac2737d015ed2018bd14436ee7b806c05fca809b8ac8cf8 --repo tom171296/CraftedSpecially --bundle-from-oci --cert-identity https://github.com/tom171296/CraftedSpecially/.github/workflows/ci.yml@refs/heads/main --cert-oidc-issuer https://token.actions.githubusercontent.com --source-ref refs/heads/main --deny-self-hosted-runners --predicate-type https://slsa.dev/provenance/v1 --format json
```
