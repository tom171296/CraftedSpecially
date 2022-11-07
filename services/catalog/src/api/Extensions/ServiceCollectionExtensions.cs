using CraftedSpecially.catalog.application.CommandHandlers;
using Microsoft.Extensions.Configuration;

namespace CraftedSpecially.catalog.application;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection RegisterApplicationDependencies(this IServiceCollection services)
    {
        services.AddTransient<IRegisterProductCommandHandler, RegisterProductCommandHandler>();
        
        return services;
    }
}