using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;

namespace CraftedSpecially.Catalog.Domain.Tests.Aggregates.ProductAggregate
{
    /// <summary>
    ///     Product class that is the aggregate root of the catalog service.
    ///     Responsible for all the business rules regarding the addition of a new product.
    /// </summary>
    public class RegisterProductBuilder
    {
        public static RegisterProductCommand Build(string name)
        {
            var _productName = name;
            var _description = "test product description";

            return new RegisterProductCommand(_productName, _description);
        }
    }
}
