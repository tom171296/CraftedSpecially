using System.Threading.Tasks;

namespace Catalog.Api.Services.Brews;

public interface IBrewOrderService
{
    Task<BrewOrderResult> PlaceOrderAsync();
}

public sealed record BrewOrderResult(string Status);
