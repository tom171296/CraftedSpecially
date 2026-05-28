var builder = DistributedApplication.CreateBuilder(args);

builder.AddProject("CraftedSpecially", "../CraftedSpecially.Api/CraftedSpecially.Api.csproj")
    .WithEnvironment("APPLICATIONINSIGHTS_CONNECTION_STRING", "InstrumentationKey=79b90990-6ecb-4d02-bc65-17282f3e54c3;IngestionEndpoint=https://eastus-8.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus.livediagnostics.monitor.azure.com/;ApplicationId=a0114fb1-d64a-4185-93fd-0516fd1757be");
builder.Build().Run();
