using CraftedSpecially.Application.Common.Interfaces;
using CraftedSpecially.Catalog.Application.Interfaces;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;

namespace CraftedSpecially.Catalog.Application.Features.ProductRegistration;

public class RegisterProductHandler : ICommandHandler<RegisterProductCommand>
{
    private readonly IProductService _productService;
    private readonly IProductRepository _productRepository;

    public RegisterProductHandler(IProductService productService,
        IProductRepository productRepository)
    {
        _productService = productService;
        _productRepository = productRepository;
    }

    public async ValueTask Handle(RegisterProductCommand command)
    {
        var product = new Product();

        await product.RegisterProductAsync(command, _productService);

        await _productRepository.AddAsync(product);

        var domainEvents = product.GetDomainEvents();
    }
}
