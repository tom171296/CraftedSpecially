using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;

namespace CraftedSpecially.Catalog.Application.Services;

public class ProductService : IProductService
{
    public ValueTask<bool> IsExistingProductAsync(string ProductName)
    {
        throw new NotImplementedException();
    }
}
