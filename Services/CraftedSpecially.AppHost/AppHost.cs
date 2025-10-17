var builder = DistributedApplication.CreateBuilder(args);

builder.AddProject("Catalog", "../Catalog/Catalog.Api/Catalog.Api.csproj");
builder.Build().Run();
