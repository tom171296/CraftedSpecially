using CraftedSpecially.catalog.application.CommandHandlers;
using Microsoft.Extensions.DependencyInjection;

namespace CraftedSpecially.catalog.application;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddApplicationDependencies(this IServiceCollection services)
    {
        services.AddTransient<IRegisterProductCommandHandler, RegisterProductCommandHandler>();
        
        return services;
    }
}