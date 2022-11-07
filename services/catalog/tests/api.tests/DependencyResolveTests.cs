using System.Reflection;
using FluentAssertions;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.ApplicationParts;
using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;

namespace CraftedSpecially.catalog.api.tests;

public class DepedencyResolveTests
{
    private IServiceCollection _configuredServices;
    private IServiceProvider _serviceProvider;

    
    public DepedencyResolveTests()
    {
        Type startUpType = typeof(Startup);

        WebHost.CreateDefaultBuilder().UseStartup(startUpType);
        var webHost = WebHost
            .CreateDefaultBuilder<Startup>(null)
            .ConfigureTestServices(serviceCollection => _configuredServices = serviceCollection)
            .Build();

        _configuredServices.Should().NotBeNull();

        _serviceProvider = webHost.Services;
    }

    [Fact]
    public void Api_AllDependencies_MustBeResolvable()
    {
        // Act
        List<object> resolvedServices = new();

        foreach (var service in _configuredServices)
        {
            Type serviceType = service.ServiceType;

            var resolvedService = ResolveService(_serviceProvider, serviceType);

            resolvedServices.Add(resolvedService);
        }

        // Assert
        resolvedServices.Should().NotContainNulls("Service is not resolvable");
    }

    [Fact]
    public void Api_AllControllers_MustBeResolvable()
    {
        // Arrange
        IList<TypeInfo> controllerTypes = ControllerTypes(_serviceProvider);

        var webHostWithControllersAsService = WebHost.CreateDefaultBuilder<Startup>(null)
            .ConfigureTestServices(services =>
            {
                foreach (var singleController in controllerTypes)
                {
                    services.AddScoped(singleController);
                }
            })
            .Build();

        IServiceProvider controllerProvider = webHostWithControllersAsService.Services;

        List<object> resolvedControllers = new();
        foreach (var singleControllerType in controllerTypes)
        {
            var resolveService = ResolveService(controllerProvider, singleControllerType);
            resolvedControllers.Add(resolveService);
        }

        // Assert
        resolvedControllers.Should().NotContainNulls("Controller is not resolvable");
    }

    private IList<TypeInfo> ControllerTypes(IServiceProvider serviceProvider)
    {
        var applicationPartManager = serviceProvider.GetRequiredService<ApplicationPartManager>();
        var controllerFeature = new ControllerFeature();
        applicationPartManager.PopulateFeature(controllerFeature);
        return controllerFeature.Controllers;
    }

    private object ResolveService(IServiceProvider serviceProvider, Type serviceType)
    {
        Type resolvableType = serviceType;

        // special case for open-generics
        if (serviceType.IsGenericType && !serviceType.IsConstructedGenericType)
        {
            resolvableType = ConstructGenericType(serviceType);
        }

        object resolvedService = null;

        try
        {
            using var scope = serviceProvider.CreateScope();
            var scopedserviceProvider = scope.ServiceProvider;

            resolvedService = scopedserviceProvider.GetService(resolvableType);
        }
        catch (Exception e)
        {
            Console.WriteLine($"ERROR: {e.Message}");
        }

        if (resolvedService != null)
        {
            Console.WriteLine($"SUCCESS: '{resolvableType}' resolved OK.");
        }
        else
        {
            Console.WriteLine($"ERROR: '{resolvableType}' is not successfully resolved!");
        }

        return resolvedService;
    }

    private static Type ConstructGenericType(Type serviceType)
    {
        Type[] genericArguments = serviceType.GetGenericArguments();
        Type[] concreteGenericArguments = genericArguments.Select(t => t.BaseType).ToArray();

        return serviceType.MakeGenericType(concreteGenericArguments);
    }
}