## 1. Prerequisites

- [x] 1.1 Create a federated credential on the existing workload identity for the GitHub Actions OIDC issuer (`repo:tom171296/CraftedSpecially:ref:refs/heads/main`), or add it to the workload identity Bicep module
- [x] 1.2 Add `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, and `ACR_REGISTRY` as GitHub Actions environment secrets (or repo secrets) for the Deployment environment

## 2. CI — Push image to ACR

- [x] 2.1 Add `id-token: write` permission to the `build` job in `.github/workflows/ci.yml`
- [x] 2.2 Add `azure/login` step to the `build` job using OIDC (after Docker build, before push)
- [x] 2.3 Add a `docker/login-action` step for the ACR endpoint (`<registry>.azurecr.io`)
- [x] 2.4 Update `docker/build-push-action` to push to ACR with tags `sha-${{ github.sha }}` and `latest` (conditioned on `github.ref == 'refs/heads/main'`)

## 3. Kubernetes manifests

- [x] 3.1 Create `infra/k8s/crafted-specially/deployment.yaml` — `Deployment` in namespace `crafted-specially`, referencing the ACR image, port 8080, non-root `securityContext`
- [x] 3.2 Create `infra/k8s/crafted-specially/service.yaml` — `ClusterIP` `Service` routing port 80 → 8080 with selector `app: crafted-specially`

## 4. Argo CD Application

- [x] 4.1 Create `infra/k8s/argocd/apps/crafted-specially.yaml` — Argo CD `Application` pointing to `infra/k8s/crafted-specially/`, namespace `crafted-specially`, with `CreateNamespace=true` and automated sync (selfHeal + prune)

## 5. Verification

- [ ] 5.1 Merge to `main` and confirm CI pushes image to ACR (check ACR repository in Azure portal)
- [ ] 5.2 Confirm Argo CD root app discovers the new `crafted-specially` Application and reports `Synced`
- [ ] 5.3 Confirm the `crafted-specially` namespace is created and the Pod reaches `Running` state
- [ ] 5.4 Confirm in-cluster traffic can reach the Service on port 80
