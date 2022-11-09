namespace CraftedSpecially.catalog.domain.Aggregates.ProductAggregate;

public interface IProductRepository
{
    Task CreateProductAsync(Product product);
}