using System.Threading.Tasks;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;
using Moq;

namespace CraftedSpecially.Catalog.Domain.Tests.Mocks;

internal class ProductServiceMock
{
    internal static Mock<IProductService> ForExistingProduct()
    {
        return CreateMock(true);
    }

    internal static Mock<IProductService> ForNonExisting()
    {
        return CreateMock(false);
    }

    private static Mock<IProductService> CreateMock(bool existing)
    {
        var mock = new Mock<IProductService>();
        mock
            .Setup(x => x.IsExistingProductAsync(It.IsAny<string>()))
            .ReturnsAsync(existing);

        return mock;
    }
}