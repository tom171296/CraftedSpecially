# Pre-commit Setup

This repository includes pre-commit hooks to ensure code quality and security.

## Installation

1. Install pre-commit:

   ```bash
   pip install pre-commit
   ```

2. Install the hooks:
   ```bash
   pre-commit install
   ```

## What's Included

### Security

- **gitleaks**: Detects hardcoded secrets, API keys, and credentials

### .NET Code Quality

- **dotnet format**: Automatically formats C# code according to .editorconfig
- **dotnet build**: Ensures code compiles before commit

### General File Quality

- **trailing-whitespace**: Removes trailing whitespace
- **end-of-file-fixer**: Ensures files end with newline
- **check-yaml**: Validates YAML syntax (supports multi-document files)
- **check-json**: Validates JSON syntax (excludes VS Code config files)
- **check-merge-conflict**: Prevents committing merge conflict markers
- **check-case-conflict**: Prevents case-sensitive filename conflicts
- **check-added-large-files**: Prevents committing large files (>1MB)
- **prettier**: Formats YAML, JSON, and Markdown files

## Manual Execution

Run all hooks on all files:

```bash
pre-commit run --all-files
```

Run specific hook:

```bash
pre-commit run gitleaks --all-files
pre-commit run dotnet-format --all-files
```

## Configuration

The configuration is in `.pre-commit-config.yaml`. Key features:

- Gitleaks runs on all commits to detect secrets
- .NET formatting and build validation for C# files
- File cleanup hooks for consistent formatting
- Prettier for YAML/JSON/Markdown formatting
