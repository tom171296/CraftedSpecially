using CraftedSpecially.Domain.Common;
namespace CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;

public record RegisterProductCommand(string Name, string Description) : Command; 