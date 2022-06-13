using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Events;
using CraftedSpecially.Shared.Domain;

namespace CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;

public class Product
{
    private Product(Guid id, string name, string description)
    {
        Id = id;
        Name = name;
        Description = description;
    }

    public Guid Id { get; }
    public string Name { get; }
    public string Description { get; }

    public static RegisterProductCommandResponse RegisterProduct(RegisterProductCommand command)
    {
        var product = new Product(Guid.NewGuid(), command.Name, command.Description);
        var evt = new ProductRegisteredEvent(product.Id, product.Name, product.Description);

        return new RegisterProductCommandResponse (
            product,
            new IDomainEvent[] { evt}
        );
    }
}