using CraftedSpecially.catalog.domain.Aggregates.ProductAggregate;
using infrastructure.Repositories;
using Microsoft.Extensions.DependencyInjection;

namespace CraftedSpecially.catalog.infrastructure.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddInfrastructureDependencies(this IServiceCollection services)
    {
        services.AddScoped<IProductRepository, ProductRepository>();
        
        return services;
    }
}