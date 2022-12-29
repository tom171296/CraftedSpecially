using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;
using Microsoft.AspNetCore.Mvc;

namespace CraftedSpecially.Catalog.Interface.WebApi.Controllers;

[ApiController]
[Route("productmanagement/command")]
public class CommandController : ControllerBase
{
    public CommandController()
    {
    }

    [HttpPost("registerproduct")]
    public async Task<IActionResult> RegisterProduct([FromBody] RegisterProductCommand command)
    {
        return Ok();
    }
}