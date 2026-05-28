#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <rekor-url>"
  echo "Example: $0 'https://rekor.sigstore.dev/api/v1/log/entries?logIndex=1683615707'"
  exit 1
fi

REKOR_URL="$1"

CERT=$(curl -s "$REKOR_URL" \
  | jq -r 'to_entries[0].value.body | @base64d | fromjson | .spec.signatures[0].verifier | @base64d')

echo "=== OIDC Issuer ==="
echo "$CERT" | openssl x509 -noout -text 2>/dev/null | grep -A1 "1.3.6.1.4.1.57264.1.1"

echo "=== Signer Email ==="
echo "$CERT" | openssl x509 -noout -text 2>/dev/null | grep -Eo "email:[^,]+"
