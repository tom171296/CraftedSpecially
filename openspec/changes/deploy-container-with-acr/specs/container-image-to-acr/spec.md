## ADDED Requirements

### Requirement: CI pushes container image to ACR on merge to main
The CI pipeline SHALL authenticate to Azure Container Registry using OIDC federated identity (no stored credentials) and push the built image on every successful merge to `main`. The image SHALL be tagged with the full Git SHA and with `latest`.

#### Scenario: Successful push on main merge
- **WHEN** a commit is merged to `main` and the build job succeeds
- **THEN** the image is pushed to ACR with tags `sha-<git-sha>` and `latest`

#### Scenario: PR builds do not push to ACR
- **WHEN** a pull request triggers the CI workflow
- **THEN** the Docker image is built but NOT pushed to ACR

#### Scenario: ACR login fails
- **WHEN** the OIDC federated credential is missing or the workload identity lacks write access to ACR
- **THEN** the CI job fails with a descriptive authentication error and no image is pushed

### Requirement: CI uses OIDC to authenticate to Azure — no long-lived secrets
The build job SHALL use `azure/login` with `client-id`, `tenant-id`, and `subscription-id` sourced from GitHub Actions environment secrets, relying on the OIDC token exchange. No ACR admin password or service principal client secret SHALL be stored in GitHub secrets.

#### Scenario: OIDC token exchange succeeds
- **WHEN** the build job runs on `main` with a valid federated credential configured
- **THEN** `azure/login` succeeds and subsequent ACR operations authenticate without a stored password

#### Scenario: Missing federated credential
- **WHEN** no federated credential is configured for the `github.ref` / `github.repository` claim
- **THEN** `azure/login` fails and the job reports an authentication error
