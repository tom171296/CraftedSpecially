using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;
using CraftedSpecially.Domain.Common;

namespace CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.DomainEvents;

public record ProductRegisteredEvent(
    string Name, 
    string Description) : Event
{
    public static ProductRegisteredEvent FromCommand(RegisterProductCommand command) => 
        new(
            command.Name, 
            command.Description
        );
}