using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate;

namespace CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;

public interface IProductService
{
    ValueTask<Product> IsExistingProductAsync(string ProductName);
}