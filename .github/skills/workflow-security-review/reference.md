# GitHub Actions Security Reference

Detailed security patterns, vulnerability examples, and remediation guidance for GitHub Actions workflows.

## Common Vulnerabilities

### 1. Script Injection via Untrusted Input
**Vulnerable:**
```yaml
- name: Comment on PR
  run: |
    echo "Comment: ${{ github.event.comment.body }}"
```

**Secure:**
```yaml
- name: Comment on PR
  env:
    COMMENT_BODY: ${{ github.event.comment.body }}
  run: |
    echo "Comment: $COMMENT_BODY"
```

### 2. Unpinned Actions
**Vulnerable:**
```yaml
- uses: actions/checkout@v4
- uses: some-org/some-action@main
```

**Secure:**
```yaml
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
- uses: some-org/some-action@1234567890abcdef1234567890abcdef12345678  # v1.2.3
```

### 3. Excessive Permissions
**Vulnerable:**
```yaml
# No permissions defined - inherits all
jobs:
  build:
    runs-on: ubuntu-latest
```

**Secure:**
```yaml
permissions:
  contents: read
  
jobs:
  build:
    runs-on: ubuntu-latest
```

### 4. Dangerous Triggers with Secrets
**Vulnerable:**
```yaml
on: pull_request_target

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.sha }}  # Checks out untrusted code
      - run: npm install && npm test  # Runs untrusted code with secrets access
```

**Secure:**
```yaml
on: pull_request  # Use pull_request instead

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm install && npm test
```

## Best Practices

### 1. Pin Action Versions to Commit SHAs
Always pin actions to a specific commit SHA to prevent supply chain attacks:
- Add a comment with the version tag for readability
- Update regularly and verify changes before updating pins
- Use Dependabot to automate updates with security reviews

### 2. Apply Least Privilege Principle
Limit permissions to the minimum required:
```yaml
permissions:
  contents: read        # Most workflows only need read access
  pull-requests: write  # Add specific permissions as needed
```

### 3. Protect Against Script Injection
- **Always** use environment variables for untrusted input
- Never use `${{ }}` directly in `run:` with user-controlled data
- Risky fields include:
  - `github.event.issue.title`, `github.event.issue.body`
  - `github.event.comment.body`
  - `github.event.pull_request.title`, `github.event.pull_request.body`
  - `github.head_ref` (branch names can be attacker-controlled)
  - User-submitted emails, names, or labels

### 4. Secure Workflow Triggers
- Prefer `pull_request` over `pull_request_target` when possible
- If using `pull_request_target`, never checkout or execute code from the PR
- Use `workflow_run` carefully - it runs with write permissions

### 5. Protect Secrets
- Use environment secrets with appropriate access controls
- Never echo secrets in logs
- Use `if: github.event.pull_request.head.repo.full_name == github.repository` to prevent secret access from forks
- Consider using OIDC for cloud provider authentication instead of long-lived credentials

### 6. Use Secure Defaults
```yaml
defaults:
  run:
    shell: bash -euo pipefail {0}  # Fail on errors and undefined variables
```

### 7. Enable Security Features
- Enable Dependabot for Actions in repository settings
- Use CodeQL or similar SAST tools to scan workflows
- Enable branch protection and require status checks

## Tools for Security Analysis

- **Actionlint**: Linter for GitHub Actions workflows
- **Semgrep**: Static analysis with GitHub Actions security rules
- **GitHub Advanced Security**: CodeQL scanning for workflows
- **StepSecurity Harden-Runner**: Runtime security for workflows

## Remediation Checklist

- [ ] All third-party actions pinned to full commit SHAs
- [ ] Explicit `permissions:` set on all workflows
- [ ] No `${{ }}` expressions in `run:` blocks with untrusted input
- [ ] Untrusted input bound to environment variables
- [ ] `pull_request_target` workflows reviewed for security
- [ ] Secrets not exposed in logs or accessible to forks
- [ ] Branch protection enabled with required reviews
- [ ] Dependabot enabled for Actions updates
- [ ] Workflow runs monitored for anomalies