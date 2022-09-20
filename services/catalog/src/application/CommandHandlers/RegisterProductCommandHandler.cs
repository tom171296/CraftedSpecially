using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate;
using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate.Commands;

namespace CraftedSpecially.catalog.application.CommandHandlers;

public class RegisterProductCommandHandler
{
    public RegisterProductCommandResponse ExecuteAsync(RegisterProductCommand command)
    {
        var response = Product.Register(command);
    }
}