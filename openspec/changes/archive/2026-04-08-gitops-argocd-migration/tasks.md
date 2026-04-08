## 1. ArgoCD Installation Manifests

- [x] 1.1 Create `infra/k8s/argocd/values.yaml` with ArgoCD Helm chart configuration (disable Dex, set server insecure mode for internal use, resource limits)
- [x] 1.2 Create `infra/k8s/argocd/namespace.yaml` defining the `argocd` namespace
- [x] 1.3 Create `infra/k8s/argocd/bootstrap.sh` — a one-time script that installs ArgoCD via Helm and applies the root Application

## 2. Repository Access

- [x] 2.1 Create `infra/k8s/argocd/repo-secret.yaml.template` with the Secret template for the SSH deploy key (placeholder values, not the actual key)
- [x] 2.2 Document in README how to generate an SSH deploy key and create the Secret before bootstrapping

## 3. App-of-Apps Root Application

- [x] 3.1 Create `infra/k8s/argocd/root-app.yaml` — the root ArgoCD `Application` pointing to `infra/k8s/argocd/apps/` in the repository
- [x] 3.2 Create `infra/k8s/argocd/apps/` directory

## 4. Child Application Manifests

- [x] 4.1 Create `infra/k8s/argocd/apps/gateway-api-crds.yaml` — Application for Gateway API CRDs (sync wave: -2, raw manifest from upstream URL)
- [x] 4.2 Create `infra/k8s/argocd/apps/cert-manager.yaml` — Application for cert-manager Helm release + ClusterIssuers + Certificate (sync wave: -1)
- [x] 4.3 Create `infra/k8s/argocd/apps/envoy-gateway.yaml` — Application for Envoy Gateway Helm release + GatewayClass + Gateway (sync wave: -1)
- [x] 4.4 Create `infra/k8s/argocd/apps/httproutes.yaml` — Application for HTTPRoutes in `infra/k8s/routes/` (sync wave: 1)

## 5. Sync Policy Configuration

- [x] 5.1 Add `syncPolicy.automated` with `selfHeal: true` and `prune: true` to all child Application manifests
- [x] 5.2 Add `argocd.argoproj.io/sync-wave` annotations to child Application manifests per the design wave table
- [x] 5.3 Add `syncOptions: [CreateNamespace=true]` to Applications that deploy to namespaces they own (cert-manager, envoy-gateway)

## 6. Helm Source Wiring

- [x] 6.1 Update `infra/k8s/argocd/apps/cert-manager.yaml` to reference the Helm chart `jetstack/cert-manager` with `valueFiles: [infra/k8s/cert-manager/values.yaml]`
- [x] 6.2 Update `infra/k8s/argocd/apps/envoy-gateway.yaml` to reference `oci://docker.io/envoyproxy/gateway-helm` with `valueFiles: [infra/k8s/envoy-gateway/values.yaml]`
- [x] 6.3 Verify chart versions in Application manifests match the versions currently documented in `infra/k8s/README.md`

## 7. README Update

- [x] 7.1 Update `infra/k8s/README.md` to replace the manual deploy steps with the ArgoCD bootstrap procedure
- [x] 7.2 Add a "Day 2 Operations" section describing how to make changes (edit file → commit → ArgoCD syncs)
- [x] 7.3 Add a "Rollback" section describing how to revert to manual management if needed

## 8. Validation

- [ ] 8.1 Run bootstrap script against the cluster and confirm ArgoCD pods reach `Running` state
- [ ] 8.2 Confirm root Application becomes `Healthy/Synced` and all child Applications appear in the ArgoCD UI
- [ ] 8.3 Confirm all child Applications reach `Healthy/Synced` (gateway traffic unaffected)
- [ ] 8.4 Test self-heal: manually edit a managed resource and verify ArgoCD reverts it
- [ ] 8.5 Test prune: commit deletion of a test resource and verify ArgoCD removes it from the cluster
