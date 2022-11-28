namespace CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;

public interface IProductService
{
    ValueTask<bool> IsExistingProductAsync(string ProductName);
}