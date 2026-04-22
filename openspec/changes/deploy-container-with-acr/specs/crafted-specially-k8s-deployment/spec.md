## ADDED Requirements

### Requirement: Deployment manifest runs the CraftedSpecially API container
A Kubernetes `Deployment` manifest SHALL exist at `infra/k8s/crafted-specially/deployment.yaml` describing the CraftedSpecially API workload. It SHALL reference the ACR image, expose port 8080, and run as a non-root user.

#### Scenario: Pod starts successfully
- **WHEN** the Deployment manifest is applied to the cluster
- **THEN** the Pod reaches `Running` state and the container listens on port 8080

#### Scenario: Non-root enforcement
- **WHEN** the container starts
- **THEN** the process runs as the non-root `appuser` defined in the Dockerfile and Kubernetes `securityContext` forbids privilege escalation

### Requirement: Service manifest exposes the Deployment within the cluster
A Kubernetes `Service` manifest SHALL exist at `infra/k8s/crafted-specially/service.yaml` of type `ClusterIP`, routing traffic on port 80 to the Deployment's container port 8080.

#### Scenario: In-cluster traffic reaches the API
- **WHEN** another workload or the Envoy Gateway sends a request to the Service on port 80
- **THEN** the request is forwarded to a healthy Pod on port 8080

#### Scenario: Service selects only CraftedSpecially pods
- **WHEN** the Service selector is evaluated
- **THEN** only Pods with the correct `app: crafted-specially` label are included in the endpoint slice

### Requirement: Workload runs in the `crafted-specially` namespace
All workload manifests SHALL target the `crafted-specially` namespace. The namespace SHALL be created by Argo CD using the `CreateNamespace=true` sync option.

#### Scenario: Namespace created on first sync
- **WHEN** Argo CD syncs the CraftedSpecially Application for the first time
- **THEN** the `crafted-specially` namespace is created if it does not already exist

#### Scenario: Namespace already exists
- **WHEN** the `crafted-specially` namespace already exists before sync
- **THEN** Argo CD applies the manifests without error and does not fail due to namespace conflict
