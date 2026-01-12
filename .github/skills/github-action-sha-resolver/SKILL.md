---
name: github-action-sha-resolver
description: Resolves GitHub Action tags/versions (e.g., @v4) to their full 40-character commit SHAs for security pinning.
allowed-tools: mcp_github-mcp_list_tags, mcp_github-mcp_get_tag
---

# GitHub Action SHA Resolver
This skill provides a secure workflow to identify the exact commit SHA associated with a specific version of a GitHub Action.

## Available MCP Tools
| Tool | Purpose |
|------|---------|
| `mcp_github-mcp_list_tags` | Lists all tags for a given repository |
| `mcp_github-mcp_get_tag` | Retrieves detailed information about a specific tag

## Workflow Logic
When a user asks for the SHA of an action version (e.g., `actions/checkout@v4`):

1. **Repository Identification:**
   - Parse the input into owner (`actions`) and repo (`checkout`).

2. **Tag Retrieval:**
   - Use `mcp_github-mcp_list_tags` to list available tags for the repository.
   - Search through the results to find the exact tag name match (e.g., `v4`).
   - If pagination is needed, continue fetching pages until the tag is found or exhausted.

3. **SHA Extraction:**
   - Extract the `commit.sha` from the tag object in the list response.
   - This provides the full 40-character commit SHA directly.

## Safety & Security Guidelines
- **Verify Source:** Always ensure the action is from the official or expected organization.
- **Full SHA Policy:** Only return the full 40-character hexadecimal SHA. Never return shortened SHAs for version pinning.
- **Ambiguity Check:** If multiple tags exist for a version (e.g., `v4` and `v4.1.1`), ask the user for clarification before providing a SHA.

## Example Interaction
**User:** "Give me the SHA for actions/setup-node@v3"
**Agent Action:**
1. Calls `mcp_github-mcp_list_tags(owner="actions", repo="setup-node", perPage=100)`.
2. Searches through the returned tags for `v3`.
3. Finds the tag and extracts commit SHA: `051d54f3a8c27888bd22a30b9f6d6309277c7315`.
4. **Response:** "The commit SHA for `actions/setup-node@v3` is `051d54f3a8c27888bd22a30b9f6d6309277c7315`."