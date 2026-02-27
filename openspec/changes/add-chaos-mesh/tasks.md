## 1. Helm Values File

- [x] 1.1 Create `infra/k8s/chaos-mesh/values.yaml` with `nodeSelector: agentpool: workloadpool`, `chaosDaemon.runtime: containerd`, and `chaosDaemon.socketPath: /run/containerd/containerd.sock`

## 2. ArgoCD Application Manifest

- [x] 2.1 Create `infra/k8s/argocd/apps/chaos-mesh.yaml` as an ArgoCD `Application` in namespace `argocd` with sync wave `-1`
- [x] 2.2 Add the Helm chart source pointing to `https://charts.chaos-mesh.org`, chart `chaos-mesh`, with a pinned `targetRevision` and `valueFiles: [$values/infra/k8s/chaos-mesh/values.yaml]`
- [x] 2.3 Add the Git repo `ref: values` source for the values file reference
- [x] 2.4 Set destination namespace to `chaos-mesh` with `CreateNamespace=true` and `ServerSideApply=true` sync options
- [x] 2.5 Enable automated sync with `selfHeal: true` and `prune: true`
