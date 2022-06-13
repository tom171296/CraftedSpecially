using CraftedSpecially.Shared.Domain;

namespace CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;

public record RegisterProductCommandResponse(Product? Product, IEnumerable<IDomainEvent> Events);