using CraftedSpecially.catalog.api.forms;

namespace CraftedSpecially.catalog.api.tests.testdatabuilders;

public class ProductFormBuilder
{
    private string name;
    private string description;

    public ProductFormBuilder()
    {
        SetDefaults();
    }

    public CreateProductForm Build()
    {
        return new CreateProductForm
        {
            Name = name,
            Description = description
        };
    }

    private void SetDefaults()
    {
        name = "testName";
        description = "testDescription";
    }
}