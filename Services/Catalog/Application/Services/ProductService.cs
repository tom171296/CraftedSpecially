using CraftedSpecially.Catalog.Application.Interfaces;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;

namespace CraftedSpecially.Catalog.Application.Services;

public class ProductService : IProductService
{
    private readonly IProductRepository _productRepository;

    public ProductService(IProductRepository productRepository)
    {
        _productRepository = productRepository;
    }

    public async ValueTask<bool> IsExistingProductAsync(string ProductName)
    {
        return await _productRepository.GetProductByName(ProductName) != null;
    }
}
