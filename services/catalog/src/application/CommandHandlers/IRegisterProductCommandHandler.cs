using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate.Commands;

namespace CraftedSpecially.catalog.application.CommandHandlers;

public interface IRegisterProductCommandHandler
{
    Task<RegisterProductCommandResponse> ExecuteAsync(RegisterProductCommand command);
}