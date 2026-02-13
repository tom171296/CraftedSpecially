using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;

namespace Catalog.UI;

public static class Endpoints
{
    public static IEndpointRouteBuilder MapCatalogEndpoints(this IEndpointRouteBuilder routes)
    {
        routes.MapGet("/", () => "Welcome to the Catalog.UI!");
        return routes;
    }
}
