---
name: nuget-package-implementation
description: Describes how to get usage instructions adding or implementing a Nuget package in a project, including viewing best practices and examples from the package's README file. Use this skill when you need to understand how to use a Nuget package effectively in your projects.
allowed-tools: mcp__nuget_mcp__get-package-readme, mcp__nuget_mcp__get-latest-package-version, mcp__nuget_mcp__update-package-to-version
---

# Nuget package implementation
This skill provides guidance on how to retrieve and utilize information about a Nuget package, including accessing its README file for documentation and usage instructions.

## Available MCP Tools
| Tool | Purpose |
|------|---------|
| `mcp__nuget_mcp__get-package-readme` | Retrieves the README.md file of a specified Nuget package |
| `mcp__nuget_mcp__get-latest-package-version` | Fetches the latest version of a specified Nuget package |
| `mcp__nuget_mcp__update-package-to-version` | Updates an existing package to a specific version |

## When to use this skill
Use this skill when you need to:
- Understand the purpose and functionality of a Nuget package
- Access the README file for detailed documentation
- Learn how to implement and use the package in your projects
- Explore examples and best practices provided in the package documentation
- Get insights into package features, installation instructions, and usage guidelines

## Core rules
1. Always explore the existing codebase before making any changes.
2. Always verify the package name and version before retrieving information.
3. Read the best practices and usage instructions provided in the README file.
4. Ensure compatibility of the package with your project requirements and existing dependencies.
5. Implement the package according to the guidelines specified in the documentation.

## Workflows

### Adding a new package
1. **Explore the codebase** — find the relevant `.csproj` files, read `Program.cs` (or equivalent entry point), and review `appsettings.json`. Identify the target framework, existing packages, and any infrastructure already in place that may overlap with or complement the new package.
2. Use `mcp__nuget_mcp__get-latest-package-version` to find the latest version of the package. Cross-check compatibility with the target framework found in step 1.
3. Use `mcp__nuget_mcp__get-package-readme` to fetch the README and understand setup requirements, configuration steps, and usage examples.
4. Summarize the key setup steps for the user before making changes, noting any conflicts or integration points with the existing codebase.
5. Add the package to the correct project using `dotnet add package <PackageName> --version <Version>`.
6. Configure the package according to the README instructions (e.g., service registration, configuration settings), adapting to the existing code rather than copy-pasting from the README verbatim.

### Updating an existing package
1. **Explore the codebase** — locate all `.csproj` files that reference the package and read relevant usage sites to understand how it is currently configured.
2. Use `mcp__nuget_mcp__get-latest-package-version` to check for the latest available version.
3. Use `mcp__nuget_mcp__get-package-readme` to review any breaking changes or migration steps in the README.
4. Use `mcp__nuget_mcp__update-package-to-version` to update the package to the desired version.
5. Apply any required configuration changes based on the README, taking into account the existing implementation found in step 1.
