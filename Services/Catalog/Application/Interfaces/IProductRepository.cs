using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;

namespace CraftedSpecially.Catalog.Application.Interfaces;

public interface IProductRepository
{
    ValueTask AddAsync(Product product);
    ValueTask<Product> GetProductByName(string productName);
}
