using System.Collections.Generic;
using CraftedSpecially.Shared.Domain;

namespace CraftedSpecially.catalog.domain.Aggregates.ProductAggregate.Commands;

public record RegisterProductCommandResponse(Product? Product, IEnumerable<IDomainEvent> Events);