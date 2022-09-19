using CraftedSpecially.Shared.Domain;

namespace CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Events;

public record ProductRegisteredEvent(
    Guid ProductId, 
    string Name, 
    string Description) : IDomainEvent;