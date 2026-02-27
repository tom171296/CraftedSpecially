using Catalog.Application.GetAllBeers;
using Catalog.Infrastructure;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.DependencyInjection;

namespace Catalog.UI;

public static class Endpoints
{
    public static IServiceCollection AddCatalogServices(this IServiceCollection services)
    {
        services.AddScoped<IBeerRepository, BeerRepository>();
        services.AddScoped<GetAllBeersHandler>();
        return services;
    }

    public static IEndpointRouteBuilder MapCatalogEndpoints(this IEndpointRouteBuilder routes)
    {
        routes.MapGet("/beers", (GetAllBeersHandler handler) => handler.Handle());
        return routes;
    }
}
