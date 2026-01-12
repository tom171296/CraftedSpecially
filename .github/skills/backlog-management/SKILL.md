---
name: backlog-management
description: Create and edit issues and bugs using GitHub Issues.
allowed-tools: mcp__github__list_issues, mcp__github__get_issue, mcp__github__create_issue, mcp__github__update_issue, mcp__github__add_issue_comment
---

# Backlog Management

This skill manages backlog items using GitHub Issues. It handles creating and editing issues and bugs.

## When to Use This Skill

Use this skill when you need to:
- Create new issues or bug reports
- Update existing issues
- Close or reopen issues
- Add comments to issues

## Creating Issues

Use `mcp__github__create_issue` with the appropriate template:

- [Feature/Enhancement](./templates/feature.md) - For new features or improvements
- [Bug Report](./templates/bug.md) - For bugs with reproduction steps
- [Quick Issue](./templates/quick.md) - For minor tasks

**Labels to apply:**
- Type: `bug`, `feature`, `enhancement`, `documentation`, `tech-debt`
- Priority: `priority:critical`, `priority:high`, `priority:medium`, `priority:low`
- Size: `size:XS`, `size:S`, `size:M`, `size:L`, `size:XL`

## Updating Issues

Use `mcp__github__update_issue` to:
- Change title or description
- Add or remove labels
- Assign or unassign users
- Set or change milestone
- Close or reopen (`state: "open"` or `state: "closed"`)

Use `mcp__github__add_issue_comment` to add context or updates.

## Repository Context

When invoked, determine the repository from:
1. User-provided `owner/repo`
2. Current git remote origin
3. Ask the user if not determinable

Always confirm the repository before making changes.
