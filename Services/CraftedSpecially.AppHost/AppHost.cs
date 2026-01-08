var builder = DistributedApplication.CreateBuilder(args);

builder.AddProject("Catalog", "../Catalog/Catalog.Api/Catalog.Api.csproj")
    .WithEnvironment("APPLICATIONINSIGHTS_CONNECTION_STRING", "TODO")
    .WithEnvironment("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4317");
builder.Build().Run();
