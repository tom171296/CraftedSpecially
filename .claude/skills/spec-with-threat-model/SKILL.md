---
name: spec-with-threat-model
description: Creates an AI-ready feature specification that includes an implementation plan and a threat model analysis. Use this skill when you want to define a new feature or change that will be implemented later by an AI agent, and you want both a clear implementation plan and a security threat model before any code is written.
---

# Feature Specification with Threat Model

Creates a structured specification document for a feature or change, combining an implementation plan with a threat model analysis produced by a dedicated sub-agent. The output is designed to be consumed by an AI coding agent in a later session.

## When to use
Use this skill when you want to:
- Define a new feature before implementation begins
- Produce a spec that an AI agent can follow without further clarification
- Ensure security risks are identified and addressed before coding starts
- Generate a threat model as part of the planning process

## Workflow

### Step 1 — Gather context
1. Ask the user (or infer from context) what feature or change they want to specify.
2. Explore the relevant parts of the codebase to understand:
   - Existing architecture and module boundaries (see `CLAUDE.md` for project structure)
   - Related domain entities, services, and endpoints that the feature will touch
   - Any existing patterns (e.g., vertical slicing, CQRS) that the implementation must follow
3. If anything is ambiguous, ask the user for clarification before proceeding.

### Step 2 — Launch threat model sub-agent (in parallel with Step 3)
Spawn a sub-agent with `subagent_type: general-purpose` to perform the threat model analysis **in parallel** with drafting the implementation plan. Provide the sub-agent with:
- The feature description
- The relevant codebase context gathered in Step 1
- The following instructions:

  > Perform a threat model analysis for the described feature using the STRIDE methodology (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege).
  >
  > For each applicable STRIDE category:
  > - Identify concrete threats relevant to this feature
  > - Assess likelihood (Low / Medium / High) and impact (Low / Medium / High)
  > - Propose a specific mitigation or control
  >
  > Conclude with:
  > - A prioritised list of the top risks (highest combined likelihood + impact first)
  > - Any security assumptions or prerequisites the implementation must satisfy
  >
  > Return the analysis in structured Markdown.

### Step 3 — Draft the implementation plan (in parallel with Step 2)
While the threat model sub-agent runs, draft the implementation plan with the following sections:

1. **Goal** — one-paragraph summary of what the feature achieves and why
2. **Scope** — what is in scope and explicitly out of scope
3. **Affected modules** — list the modules and projects that need changes
4. **Data model changes** — new or modified entities, value objects, or database schema
5. **Use cases / vertical slices** — for each new use case, specify:
   - Name (e.g., `CreateOrder`)
   - Input / output contract
   - Steps the handler must perform
   - Domain rules or invariants to enforce
6. **API / UI surface** — new or modified endpoints, commands, events, or UI elements
7. **Dependencies** — new packages, external services, or infrastructure components required
8. **Testing requirements** — what must be covered by unit, integration, or end-to-end tests
9. **Open questions** — anything that must be resolved before or during implementation

### Step 4 — Merge and produce the specification document
1. Wait for the threat model sub-agent to complete.
2. Integrate the threat model results into the implementation plan:
   - Add a **Security considerations** section after the use cases, referencing the top risks
   - Annotate individual use cases with any mitigations that must be implemented as part of that slice
3. Write the final specification to a Markdown file at:
   ```
   docs/specs/<kebab-case-feature-name>.md
   ```
   If the `docs/specs/` directory does not exist, create it.

### Step 5 — Review with the user
Present a concise summary of:
- The implementation plan highlights
- The top 3 security risks and their mitigations

Ask the user to review the generated spec file and confirm whether it is ready for AI implementation or requires further refinement.

## Output format

The generated spec file must follow this structure:

```markdown
# Specification: <Feature Name>

**Status:** Draft | Ready for implementation
**Created:** <date>
**Author:** <user or "Claude Code">

---

## Goal
...

## Scope
### In scope
...
### Out of scope
...

## Affected modules
...

## Data model changes
...

## Use cases
### <UseCaseName>
**Input:** ...
**Output:** ...
**Steps:** ...
**Domain rules:** ...
**Security notes:** ...

## API / UI surface
...

## Dependencies
...

## Testing requirements
...

## Security considerations
*(Generated by threat model sub-agent — STRIDE analysis)*

### Top risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| ...  | ...        | ...    | ...        |

### Full STRIDE analysis
...

## Open questions
...
```

## Core rules
1. Do not write any implementation code — this skill produces specifications only.
2. Always run the threat model sub-agent; never skip it even for seemingly simple features.
3. Keep use cases aligned with the vertical slicing pattern used in this project.
4. Security mitigations must be actionable — vague statements like "validate input" are not acceptable; specify what validation and where.
5. The spec must be self-contained so that an AI agent can implement it in a fresh conversation without needing additional context.
