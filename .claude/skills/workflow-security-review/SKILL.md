---
name: Workflow Security Review
description: Guide for reviewing GitHub Actions for security vulnerabilities.
allowed-tools: github:get_ref, github:list_tags, github:get_repository
---

# Workflow Security Review

This skill analyzes GitHub Actions workflows for security vulnerabilities and misconfigurations that could lead to code injection, privilege escalation, or credential exposure.

## When to use this skill

Use this skill when you need to:
- Validate the security of your GitHub Actions workflows
- Review pull requests that modify workflow files
- Identify potential security risks in your CI/CD pipelines
- Ensure compliance with security best practices in your automation processes
- Audit workflows before deploying to production
- Investigate security incidents involving GitHub Actions

## Analyzing GitHub Actions

### Step-by-step Analysis Process

1. **Locate Workflow Files**
   - Check `.github/workflows/` directory for all `*.yml` and `*.yaml` files

2. **Review Trigger Events**
   - Identify workflows triggered by `pull_request_target`, `workflow_run`, or `issue_comment`
   - These events have elevated privileges and access to secrets
   - Verify that untrusted code is not executed with these triggers

3. **Inspect Action Pinning**
   - Check if third-party actions use commit SHAs instead of tags
   - Example: `actions/checkout@a12b3c4...` ✅ vs `actions/checkout@v4` ⚠️

4. **Analyze Script Injection Risks**
   - Look for `${{ }}` expressions in `run:` blocks
   - Check for unsafe context variables in scripts
   - Identify untrusted input from: `github.event.issue.title`, `github.event.comment.body`, `github.event.pull_request.title`, `github.head_ref`

5. **Review Permissions**
   - Verify `permissions:` are set at job or workflow level
   - Ensure least privilege (use `contents: read` as default)
   - Flag workflows without explicit permissions (inherit all by default)

6. **Check Secret Handling**
   - Ensure secrets are not logged or exposed in outputs
   - Verify secrets are not used in pull requests from forks
   - Check for hardcoded credentials or tokens

## Additional resources

For detailed vulnerability patterns, secure code examples, best practices, and remediation guidance, see [reference.md](./reference.md).
