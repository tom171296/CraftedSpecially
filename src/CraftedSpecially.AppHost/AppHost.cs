var builder = DistributedApplication.CreateBuilder(args);

builder.AddProject("CraftedSpecially", "../CraftedSpecially.Api/CraftedSpecially.Api.csproj")
    .WithEnvironment("APPLICATIONINSIGHTS_CONNECTION_STRING", "TODO")
    .WithEnvironment("OTEL_EXPORTER_OTLP_ENDPOINT", "http://localhost:4317");
builder.Build().Run();
