---
name: Nuget package implementation
description: Describes how to get usage instructions for a Nuget package.
allowed-tools: mcp_nuget_get-package-readme, mcp_nuget_get-latest-package-version
---

# Nuget package implementation
This skill provides guidance on how to retrieve and utilize information about a Nuget package, including accessing its README file for documentation and usage instructions.

## Available MCP Tools
| Tool | Purpose |
|------|---------|
| `mcp_nuget_get-package-readme` | Retrieves the README.md file of a specified Nuget package |
| `mcp_nuget_get-latest-package-version` | Fetches the latest version of a specified Nuget package |

## When to use this skill
Use this skill when you need to:
- Understand the purpose and functionality of a Nuget package
- Access the README file for detailed documentation
- Learn how to implement and use the package in your projects
- Explore examples and best practices provided in the package documentation
- Get insights into package features, installation instructions, and usage guidelines

## Core rules
1. Always verify the package name and version before retrieving information.
2. Read the best practices and usage instructions provided in the README file.
3. Ensure compatibility of the package with your project requirements.
4. Implement the package according to the guidelines specified in the documentation.

## Workflows

### Retrieving Package guidelines
- use the `mcp_nuget_get-latest-package-version` tool to find the latest version of the Nuget package you are interested in.
- use the `mcp_nuget_get-package-readme` tool to fetch the README.md file of the Nuget package.
- Review the README.md file to understand the package's purpose, installation instructions, usage examples, and any other relevant information.
