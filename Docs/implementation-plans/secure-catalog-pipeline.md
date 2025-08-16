# Requirements Document: Secure CI/CD Pipeline for Catalog Service

## 0. Task Analysis

**Feature:**  
Implement a secure GitHub Actions pipeline for the Catalog service to automate build, test, security scanning, artifact publishing, and deployment to Azure Kubernetes Service (AKS), following security best practices.

**Acceptance Criteria (from `TASK.md`):**
- Workflow includes restoring dependencies, building, testing (MSTest), static code analysis (CodeQL), dependency vulnerability checks, artifact publishing, and AKS deployment.
- Secrets are managed via GitHub Secrets.
- Principle of least privilege for permissions.
- Prevent secrets from leaking in logs.
- Triggered on PRs and pushes to main.
- Pipeline fails on any security or test failure.
- Edge/failure cases: build/test/security/deployment failures stop pipeline and notify maintainers.

**Documentation:**  
Architecture docs to be added in `docs/architecture` (ARC42 template).

---

## 1. Codebase Analysis

### Existing Patterns & Conventions

- **Workflow Location:**  
  `.github/workflows/catalog-service.yml` (main pipeline file, non-empty)  
  `.github/workflows/catalog.yml` (empty, ignore)

- **Project Structure:**  
  - API: `Services/Catalog/Catalog.Api/`
  - Application logic: `Services/Catalog/Catalog.Application/`
  - Tests: `Services/Catalog/Catalog.Tests/` (MSTest, see `Catalog.Tests.csproj`)
  - Dockerfile: `Services/Catalog/dockerfile` (multi-stage, non-root user, healthcheck)
  - No existing test classes, but MSTest is configured.

- **Deployment:**  
  - AKS defined in `Infrastructure/runtime-infrastructure/aks/aks.bicep`
  - Load testing and chaos engineering in Bicep under `Infrastructure/management-governance/continuous-validation/`

- **Security Practices:**  
  - Dockerfile uses non-root user, exposes only necessary port, has healthcheck.
  - No hardcoded secrets in code or Dockerfile.

### Code Examples

- **Dockerfile Security:**
  ```dockerfile
  # Security: Create non-root user and switch to it
  RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
  USER appuser
  ```

- **MSTest Project Reference:**
  ```xml
  <Project Sdk="MSTest.Sdk/3.9.0">
    <TargetFramework>net10.0</TargetFramework>
    ...
  </Project>
  ```

- **Workflow Permissions:**
  ```yaml
  permissions:
    contents: read
    packages: write
  ```

---

## 2. External Research

- **GitHub Actions Security Best Practices:**  
  - https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions
  - https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions
  - https://docs.github.com/en/actions/deployment/security-hardening-your-deployments

- **CodeQL for .NET:**  
  - https://docs.github.com/en/code-security/code-scanning/automatically-scanning-your-code-for-vulnerabilities-and-errors/about-code-scanning-with-codeql

- **Dependabot:**  
  - https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically/about-dependabot-version-updates

- **Azure AKS Deployment:**  
  - https://learn.microsoft.com/en-us/azure/aks/
  - https://github.com/Azure/aks-set-context

- **MSTest:**  
  - https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-with-mstest

---

## 3. Context Gathering

### Integration Points

- **Build & Test:**  
  - Use `dotnet restore`, `dotnet build`, `dotnet test` in workflow.
  - Test project: `Services/Catalog/Catalog.Tests/`

- **Static Analysis:**  
  - Use CodeQL action for .NET.

- **Dependency Scanning:**  
  - Use `dotnet list package --vulnerable` and/or Dependabot.

- **Artifact Publishing:**  
  - Docker image built from `Services/Catalog/dockerfile`, pushed to GHCR.

- **Deployment:**  
  - Use Azure login and AKS set context actions.
  - Deploy manifests (not found in repo, but referenced in workflow as `./Services/Catalog/catalog-service.yml`).

- **Secrets:**  
  - Use `GITHUB_TOKEN` and `AZURE_CREDENTIALS` from GitHub Secrets.

- **Load Testing & Chaos:**  
  - Azure Load Testing and Chaos Mesh steps are present in workflow.

### Version-Specific Considerations

- .NET 10.0 (preview, as per csproj and Dockerfile)
- Use latest stable GitHub Actions and Azure actions.

---

## Implementation Blueprint

### High-Level Approach

1. **Trigger:**  
   - On PR and push to main.

2. **Permissions:**  
   - Set least privilege in workflow.

3. **Restore, Build, Test:**  
   - Use `dotnet` CLI for restore, build, and test.
   - Fail pipeline on any error.

4. **Static Analysis:**  
   - Run CodeQL scan.

5. **Dependency Scanning:**  
   - Run `dotnet list package --vulnerable`.
   - Optionally, configure Dependabot.

6. **Build & Publish Docker Image:**  
   - Use multi-stage Dockerfile.
   - Push to GHCR.

7. **Deploy to AKS:**  
   - Use Azure login and AKS context actions.
   - Deploy manifests.

8. **Post-Deployment Validation:**  
   - Run load tests and chaos experiments.

9. **Secrets Management:**  
   - Use GitHub Secrets for all credentials.

10. **Notifications:**  
    - Notify maintainers on failure (via GitHub Actions default or custom step).

### Pseudocode

```yaml
on:
  push:
    branches: [main]
  pull_request:

jobs:
  build-test:
    ...
    steps:
      - uses: actions/checkout@v3
      - run: dotnet restore
      - run: dotnet build --no-restore
      - run: dotnet test --no-build --logger trx
      - run: dotnet list package --vulnerable
      - uses: github/codeql-action/init@v3
      - uses: github/codeql-action/analyze@v3
      - name: Build and push Docker image
        ...
  deploy:
    needs: build-test
    ...
    steps:
      - uses: azure/login@v1
      - uses: azure/aks-set-context@v3
      - uses: azure/setup-kubectl@v3
      - run: kubectl apply -f ./Services/Catalog/catalog-service.yml
  post-deploy:
    needs: deploy
    ...
    steps:
      - uses: azure/load-testing@v1
      - uses: azure/CLI@v1 # for chaos experiment
```

### Error Handling

- Use `continue-on-error: false` (default) for all critical steps.
- Fail fast: pipeline stops on any failed build, test, or security scan.
- Notify maintainers via GitHub Actions UI and optional custom notification step.

### Ordered Task List

1. Set up workflow triggers and permissions.
2. Add steps for checkout, restore, build, test.
3. Add CodeQL and dependency scanning.
4. Build and push Docker image.
5. Deploy to AKS.
6. Run post-deployment validation (load test, chaos).
7. Ensure all secrets are referenced from GitHub Secrets.
8. Add notification on failure.
9. Document pipeline in `docs/architecture`.

### Validation and Testing

- Run `dotnet test` in pipeline.
- Run `dotnet list package --vulnerable`.
- Ensure CodeQL scan passes.
- Validate Docker image build and push.
- Validate AKS deployment (kubectl apply).
- Validate load test and chaos experiment steps.
- Check for secret leaks in logs.
- Confirm pipeline fails on any error.

**Validation Gates:**
- `dotnet test Services/Catalog/Catalog.Tests/`
- `dotnet list package --vulnerable`
- CodeQL scan passes
- Docker image builds and pushes to GHCR
- AKS deployment completes without error
- Load test and chaos experiment steps succeed

---

## Quality Checklist

- [x] All necessary context for autonomous implementation
- [x] Validation gates that are executable
- [x] References to existing patterns and conventions
- [x] Clear, ordered implementation path
- [x] Comprehensive error handling documentation
- [x] Main flow and alternate scenarios covered
- [x] Specific code examples and file references

**Quality Score:** 9/10  
**Rationale:**  
The requirements are comprehensive, reference all relevant code and documentation, and provide a clear, step-by-step implementation path. The only minor gap is the absence of actual test classes in the codebase, which should be addressed in parallel with pipeline implementation.

---

**Save as:**  
`docs/implementation-plans/secure-catalog-pipeline.md`
