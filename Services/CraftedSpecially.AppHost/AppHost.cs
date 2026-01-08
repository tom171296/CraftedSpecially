var builder = DistributedApplication.CreateBuilder(args);

builder.AddProject("Catalog", "../Catalog/Catalog.Api/Catalog.Api.csproj")
    .WithEnvironment("APPLICATIONINSIGHTS_CONNECTION_STRING", "InstrumentationKey=388cc7a5-d1ce-4383-9a16-73a8dbdee67e;IngestionEndpoint=https://canadacentral-1.in.applicationinsights.azure.com/;LiveEndpoint=https://canadacentral.livediagnostics.monitor.azure.com/;ApplicationId=da52ab21-4f2b-4745-b55f-053a3d44df8b")
    .WithEnvironment("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4317");
builder.Build().Run();
