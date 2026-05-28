# Provenance and attestation

This document describes the theory and implementation in crafted specially of provenance
and attestation. 

## Provenance

## Demo's

Push to the registry:

```bash
docker push ndccopenhagen.azurecr.io/crafted-specially:latest
```

Sign image:

```bash
cosign sign ndccopenhagen.azurecr.io/crafted-specially@sha256:cccfad9914f7c327e6ac1dfd3fd4becd79e00ef0eace99360d8d631f47e6a1ff```

Cosign certificate:

```bash
cosign download signature ndccopenhagen.azurecr.io/crafted-specially@sha256:cccfad9914f7c327e6ac1dfd3fd4becd79e00ef0eace99360d8d631f47e6a1ff
```

Get Rekor metadata:

```bash
./scripts/rekor-issuer.sh "https://rekor.sigstore.dev/api/v1/log/entries?logIndex=1683615707"
```

Verify image:

```bash
cosign verify ndccopenhagen.azurecr.io/crafted-specially@sha256:cccfad9914f7c327e6ac1dfd3fd4becd79e00ef0eace99360d8d631f47e6a1ff --certificate-identity t.vandenberg.96@gmail.com --certificate-oidc-issuer https://github.com/login/oauth
```

---

