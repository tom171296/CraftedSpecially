---
name: github-action-sha-resolver
description: Resolves GitHub Action tags/versions (e.g., @v4) to their full 40-character commit SHAs for security pinning.
allowed-tools: github:get_ref, github:list_tags, github:get_repository
---

# GitHub Action SHA Resolver
This skill provides a secure workflow to identify the exact commit SHA associated with a specific version of a GitHub Action.

## Workflow Logic
When a user asks for the SHA of an action version (e.g., `actions/checkout@v4`):

1. **Repository Identification:**
   - Parse the input into owner (`actions`) and repo (`checkout`).
   - Use `github:get_repository` to verify the repository exists and is not a fork.

2. **Ref Retrieval:**
   - Attempt to fetch the specific tag using `github:get_ref`.
   - The reference format should be `tags/[version_name]` (e.g., `tags/v4`).
   - If `get_ref` fails or the version is ambiguous, use `github:list_tags` to find the most relevant match.

3. **SHA Extraction:**
   - Extract the `object.sha` from the response.
   - If the tag is "annotated," the initial SHA might be the tag object; ensure you retrieve the underlying commit SHA if they differ.

## Safety & Security Guidelines
- **Verify Source:** Always ensure the action is from the official or expected organization.
- **Full SHA Policy:** Only return the full 40-character hexadecimal SHA. Never return shortened SHAs for version pinning.
- **Ambiguity Check:** If multiple tags exist for a version (e.g., `v4` and `v4.1.1`), ask the user for clarification before providing a SHA.

## Example Interaction
**User:** "Give me the SHA for actions/setup-node@v3"
**Agent Action:**
1. Calls `github:get_ref(owner="actions", repo="setup-node", ref="tags/v3")`.
2. Receives SHA: `051d54f3a8c27888bd22a30b9f6d6309277c7315`.
3. **Response:** "The commit SHA for `actions/setup-node@v3` is `051d54f3a8c27888bd22a30b9f6d6309277c7315`."