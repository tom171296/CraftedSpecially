using Catalog.Api.Services.Brews;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Catalog.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class BrewsController : ControllerBase
{
    private readonly IBrewOrderService _brewOrderService;

    public BrewsController(IBrewOrderService brewOrderService)
    {
        _brewOrderService = brewOrderService;
    }

    [HttpGet("order")]
    public async Task<ActionResult<BrewOrderResult>> PlaceOrder()
    {
        var result = await _brewOrderService.PlaceOrderAsync();

        if (result.Status == "Checkout failed")
        {
            return Problem(result.Status);
        }

        return Ok(result);
    }
}
