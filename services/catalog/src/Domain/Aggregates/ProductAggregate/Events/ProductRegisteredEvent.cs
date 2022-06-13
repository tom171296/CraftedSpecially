using CraftedSpecially.Shared.Domain;

namespace CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Events;

public record ProductRegisteredEvent(
    Guid productId, 
    string Name, 
    string Description) : IDomainEvent;