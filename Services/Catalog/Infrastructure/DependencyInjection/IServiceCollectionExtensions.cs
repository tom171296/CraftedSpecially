using CraftedSpecially.Application.Common.Interfaces;
using CraftedSpecially.Catalog.Application.Features.ProductRegistration;
using CraftedSpecially.Catalog.Application.Services;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate.Commands;

namespace Microsoft.Extensions.DependencyInjection;

public static class IServiceCollectionExtensions
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services
    )
    {
        return services
            .AddDependencies();
    }

    private static IServiceCollection AddDependencies(this IServiceCollection services)
    {
        return services
            .AddTransient<IProductService, ProductService>()
            .AddTransient<ICommandHandler<RegisterProductCommand>, RegisterProductHandler>();
    }
}