var builder = DistributedApplication.CreateBuilder(args);

builder.AddProject("CraftedSpecially", "../CraftedSpecially.Api/CraftedSpecially.Api.csproj")
    .WithEnvironment("APPLICATIONINSIGHTS_CONNECTION_STRING", "InstrumentationKey=c64f9b85-4990-4058-aa5a-325467e956e7;IngestionEndpoint=https://eastus-8.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus.livediagnostics.monitor.azure.com/;ApplicationId=093b2c32-d964-4bc6-af14-16d7c22baf1e");
builder.Build().Run();
