using CraftedSpecially.Application.Common.Interfaces;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;
using CraftedSpecially.Domain.Common;
using Microsoft.AspNetCore.Mvc;

namespace CraftedSpecially.Catalog.Interface.WebApi.Controllers;

[ApiController]
[Route("productmanagement/command")]
public class CommandController : ControllerBase
{
    [HttpPost("registerproduct")]
    public async Task<IActionResult> RegisterProduct(
        [FromBody] RegisterProductCommand command,
        [FromServices] ICommandHandler<RegisterProductCommand> commandHandler) =>
            await HandleCommand(command, commandHandler);

    private async Task<IActionResult> HandleCommand<T>(
        Command command, ICommandHandler<T> commandHandler) where T : Command
    {
        await commandHandler.Handle((T)command);
        return Ok();
    }
}
