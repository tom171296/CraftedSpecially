using CraftedSpecially.Catalog.Application.Interfaces;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;

namespace CraftedSpecially.Catalog.Infrastructure.Persistence.EFCore
{
    public class EFProductRepository : IProductRepository
    {
        public ValueTask AddAsync(Product product)
        {
            throw new NotImplementedException();
        }

        public ValueTask<Product> GetProductByName(string productName)
        {
            throw new NotImplementedException();
        }
    }
}
