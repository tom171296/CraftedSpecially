# Session Context

## User Prompts

### Prompt 1

Implement the following plan:

# Update CI for Modular Monolith

## Context
The project migrated from separate microservices (`Services/Catalog/...`) to a modular monolith (`src/` with a root solution file). The CI workflow still references old paths and an old Dockerfile that was deleted during migration.

## Changes

### 1. Create new Dockerfile
**File:** `src/CraftedSpecially.Api/Dockerfile`

Multi-stage build adapted from the old `Services/Catalog/dockerfile`, updated for the ne...

### Prompt 2

commit this

