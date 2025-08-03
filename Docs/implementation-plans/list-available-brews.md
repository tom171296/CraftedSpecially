# Requirements Document: List Available Brews

**Location:** `docs/implementation-plans/list-available-brews.md`

## 0. Task Analysis

- **Feature:** List all brews a person can order.
- **Goal:** Expose an endpoint in the Catalog service that returns all available brews.
- **Examples:** Main flow, empty catalog, service unavailable.
- **Documentation:** Update ARC42 docs in `docs/architecture` (building blocks, runtime, glossary).

## 1. Codebase Analysis

### Existing Patterns

- The Catalog service is in `Services/CraftedSpecially.Catalog/`.
- The only code file is `Program.cs`, which currently exposes a `/weatherforecast` endpoint using minimal API style.
- No models, controllers, or feature folders exist yet.
- No unit tests are present for the Catalog service.

### Architectural Conventions

- Feature slices are preferred.
- .NET 10, C#, minimal API.
- Service defaults and OpenAPI are configured in `Program.cs`.
- Cosmos DB is the intended backend (not yet implemented).

### Testing

- Unit tests required for new components.
- At least: expected use, edge case (empty), failure case (service unavailable).

## 2. External Research

- [Minimal APIs in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/minimal-apis)
- [Testing ASP.NET Core Minimal APIs](https://learn.microsoft.com/en-us/aspnet/core/test/integration-tests?view=aspnetcore-7.0)
- [arc42 Template](https://arc42.org/download)

## 3. Context Gathering

### Patterns to Mirror

- Use minimal API style as in `Program.cs`.
- Add feature slice structure (e.g., `Features/Brews/Brew.cs`, `Features/Brews/BrewEndpoints.cs`).
- Document new API in ARC42 building blocks and runtime views.

### Integration Points

- Endpoint will be added to Catalog service.
- Data source: In-memory list for now (replace with Cosmos DB later).
- Tests: Add new test project (e.g., `CraftedSpecially.Catalog.Tests`).

### Version Considerations

- .NET 10, C# 10 features allowed.

## Implementation Blueprint

### High-Level Approach

1. Define a `Brew` model.
2. Create an in-memory list of brews.
3. Add a GET endpoint `/brews` to return all brews.
4. Handle empty list and service error cases.
5. Add unit tests for all scenarios.
6. Update ARC42 documentation.

### Pseudocode

```csharp
// Brew model
public record Brew(Guid Id, string Name, string Description);

// In-memory list
var brews = new List<Brew> { ... };

// Endpoint
app.MapGet("/brews", () => brews);
```

### Error Handling

- Return 200 with empty array if no brews.
- Return 503 if service unavailable (simulate with a flag).
- Log errors using built-in logging.

### Ordered Task List

1. Create `Features/Brews/Brew.cs` for the model.
2. Create `Features/Brews/BrewEndpoints.cs` for endpoint registration.
3. Register endpoints in `Program.cs`.
4. Add in-memory data source.
5. Add error handling for empty and unavailable cases.
6. Create test project and add unit tests.
7. Update ARC42 docs:
   - Building blocks: Add Brew model and endpoint.
   - Runtime: Add request/response flow.
   - Glossary: Add "brew", "catalog", "order".

### Validation and Testing Approach

- Run `dotnet test` in the test project.
- Validate endpoint with HTTP client (e.g., `CraftedSpecially.Catalog.http`).
- Check for code quality and linting (e.g., `dotnet format`).

## Validation Gates

- [ ] All unit tests pass (`dotnet test`)
- [ ] Endpoint returns correct data for all cases
- [ ] Documentation updated in `docs/architecture`
- [ ] Code follows feature slice and minimal API conventions

## Quality Checklist

- [x] All necessary context for autonomous implementation
- [x] Validation gates that are executable
- [x] References to existing patterns and conventions
- [x] Clear, ordered implementation path
- [x] Comprehensive error handling documentation
- [x] Main flow and alternate scenarios covered
- [x] Specific code examples and file references

**Quality Score:** 9/10  
**Reason:** All requirements and context are included for autonomous implementation. The only improvement would be to add Cosmos DB integration, but for demo purposes, in-memory is sufficient.
