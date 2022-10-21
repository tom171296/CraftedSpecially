using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate;
using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate.Commands;

namespace CraftedSpecially.catalog.application.CommandHandlers;

/// <summary>
///     Responsible for handling the register product command. 
///     If a product can be registered succesfully, it will be registered in the persistence layer.
/// </summary>
public class RegisterProductCommandHandler : IRegisterProductCommandHandler
{
    private readonly IProductRepository _productRepository;

    public RegisterProductCommandHandler(IProductRepository productRepository)
    {
        _productRepository = productRepository;
    }

    public async Task<RegisterProductCommandResponse> ExecuteAsync(RegisterProductCommand command)
    {
        var response = Product.RegisterProduct(command);

        await _productRepository.CreateProductAsync(response.Product);

        return response;
    }
}