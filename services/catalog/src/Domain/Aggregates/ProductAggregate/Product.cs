using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;

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

        return new RegisterProductCommandResponse (
            product
        );
    }
}