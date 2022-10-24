using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate;
using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate.Commands;

namespace CraftedSpecially.catalog.api.tests.testdatabuilders;

public class RegisterProductCommandResponseBuilder
{
    public string ProductName { get; private set;} = "";
    public string ProductDescription { get; private set;} = "";

    public RegisterProductCommandResponseBuilder()
    {
        SetDefaults();
    }

    internal RegisterProductCommandResponse Build()
    {
        return Product.RegisterProduct(new RegisterProductCommand(ProductName, ProductDescription));
    }

    private void SetDefaults()
    {
        ProductName = "testProduct";
        ProductDescription = "testDescription";
    }
}