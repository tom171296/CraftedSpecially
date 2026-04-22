# Kubernetes Gateway Setup

This directory contains Helm values and Kubernetes manifests for the CraftedSpecially API gateway, managed via GitOps with ArgoCD.

## Components

| Component | Namespace | Purpose |
|-----------|-----------|---------|
| ArgoCD | `argocd` | GitOps controller — reconciles all components below from git |
| Envoy Gateway | `envoy-gateway-system` | Gateway API controller + Envoy data plane |
| cert-manager | `cert-manager` | Automated TLS certificate management |
| Gateway API CRDs | cluster-wide | `GatewayClass`, `Gateway`, `HTTPRoute` resources |

## Prerequisites

- `kubectl` configured against the target AKS cluster
- `helm` v3.x installed
- Internet access from the cluster (for Let's Encrypt ACME challenges and Helm chart pulls)

## Repository Access

Before bootstrapping, create the SSH deploy key and ArgoCD repository Secret:

```bash
# 1. Generate an SSH key pair (no passphrase)
ssh-keygen -t ed25519 -C "argocd-deploy-key" -f argocd-deploy-key -N ""

# 2. Add argocd-deploy-key.pub as a read-only deploy key on GitHub:
#    Repository → Settings → Deploy keys → Add deploy key (read-only)

# 3. Fill in the template and create the Secret
cp infra/k8s/argocd/repo-secret.yaml.template /tmp/repo-secret.yaml
# Edit /tmp/repo-secret.yaml:
#   - Set `url` to the SSH URL of the repository (e.g. git@github.com:org/CraftedSpecially.git)
#   - Paste the contents of argocd-deploy-key under `sshPrivateKey`
kubectl apply -f /tmp/repo-secret.yaml
rm /tmp/repo-secret.yaml argocd-deploy-key argocd-deploy-key.pub
```

> **Security**: Never commit the private key. The template file contains placeholders only.

## Bootstrap (one-time)

Set the repository URL in these files before bootstrapping (public repo can use HTTPS, private repo typically uses SSH):

- `infra/k8s/argocd/root-app.yaml`
- `infra/k8s/argocd/apps/cert-manager.yaml`
- `infra/k8s/argocd/apps/envoy-gateway.yaml`
- `infra/k8s/argocd/apps/httproutes.yaml`

Then run:

```bash
./infra/k8s/argocd/bootstrap.sh
```

This installs ArgoCD via Helm and applies the root App-of-Apps. ArgoCD then reconciles all child Applications automatically.

**Get the initial ArgoCD admin password:**
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d
```

**Access the ArgoCD UI (port-forward):**
```bash
kubectl -n argocd port-forward svc/argocd-server 8080:80
# Open: http://localhost:8080
```

## ArgoCD Application Structure

```
root (App-of-Apps)
├── gateway-api-crds   [wave -2]  — Kubernetes Gateway API CRDs v1.2.1
├── cert-manager       [wave -1]  — cert-manager v1.16.3 + ClusterIssuers + Certificate
├── envoy-gateway      [wave -1]  — Envoy Gateway v1.3.0 + GatewayClass + Gateway
└── httproutes         [wave  1]  — HTTPRoutes (infra/k8s/routes/)
```

Sync waves enforce deploy order: CRDs before controllers, controllers before custom resources.

## Initial Configuration

Before the first sync, fill in the `TODO` placeholders in the manifests:

1. `infra/k8s/cert-manager/cluster-issuer-staging.yaml` — set `spec.acme.email`
2. `infra/k8s/cert-manager/cluster-issuer-prod.yaml` — set `spec.acme.email`
3. `infra/k8s/cert-manager/certificate.yaml` — set `spec.dnsNames`
4. `infra/k8s/routes/craftedspecially-api.yaml` — set `spec.hostnames` and backend port

Commit the changes and ArgoCD will apply them automatically.

## Day 2 Operations

All cluster changes are driven by git commits — no manual `kubectl apply` or `helm upgrade` required.

**To update a manifest:**
1. Edit the file in `infra/k8s/`
2. Commit and push to `main`
3. ArgoCD detects the diff and syncs within ~3 minutes (default polling interval)

**To add a new HTTPRoute:**
1. Copy `infra/k8s/routes/craftedspecially-api.yaml` to a new file
2. Update `metadata.name`, `spec.hostnames`, `spec.rules[].matches`, and `spec.rules[].backendRefs`
3. Commit and push — the `httproutes` Application picks it up automatically

**To upgrade a Helm chart:**
1. Update `targetRevision` in the relevant Application manifest under `infra/k8s/argocd/apps/`
2. Commit and push

**To force an immediate sync (without waiting for polling):**
```bash
argocd app sync <app-name>
# or via UI: click "Sync" on the Application
```

## Rollback

**To revert a change**: revert the git commit and push — ArgoCD will reconcile back.

**To remove ArgoCD and return to manual management:**
```bash
# Remove ArgoCD (Applications are deleted, but managed resources are NOT pruned)
helm uninstall argocd -n argocd
kubectl delete namespace argocd

# Re-apply resources manually from infra/k8s/ as needed
```

> Note: Deleting ArgoCD does not delete the resources it managed (cert-manager, Envoy Gateway, etc.). Those remain running.

## Debugging

**Check Application sync status:**
```bash
kubectl -n argocd get applications
```

**View sync errors:**
```bash
kubectl -n argocd get application <name> -o jsonpath='{.status.conditions}'
```

**View Envoy proxy config (xDS dump):**
```bash
ENVOY_POD=$(kubectl -n envoy-gateway-system get pod -l gateway.envoyproxy.io/owning-gateway-name=craftedspecially-gateway -o name | head -1)
kubectl -n envoy-gateway-system exec $ENVOY_POD -- curl -s localhost:19000/config_dump | jq .
```

**Check cert-manager logs:**
```bash
kubectl -n cert-manager logs -l app=cert-manager --tail=50
```

**Configure DNS:**

Get the gateway's external IP after the `envoy-gateway` Application is Healthy:
```bash
kubectl -n envoy-gateway-system get svc -l gateway.envoyproxy.io/owning-gateway-name=craftedspecially-gateway
```

Create an A record pointing your domain to this IP.
