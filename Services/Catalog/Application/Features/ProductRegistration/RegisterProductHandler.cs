using CraftedSpecially.Application.Common.Interfaces;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;

namespace CraftedSpecially.Catalog.Application.Features.ProductRegistration;

public class RegisterProductHandler : ICommandHandler<RegisterProductCommand>
{
    private readonly IProductService _productService;

    public RegisterProductHandler(IProductService productService)
    {
        _productService = productService;
    }

    public async ValueTask Handle(RegisterProductCommand command)
    {
        var product = new Product();

        await product.RegisterProductAsync(command, _productService);
    }
}