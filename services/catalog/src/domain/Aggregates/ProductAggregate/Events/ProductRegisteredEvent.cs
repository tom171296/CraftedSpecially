using System;
using CraftedSpecially.Shared.Domain;

namespace CraftedSpecially.catalog.domain.Aggregates.ProductAggregate.Events;

public record ProductRegisteredEvent(
    Guid ProductId, 
    string Name, 
    string Description) : IDomainEvent;