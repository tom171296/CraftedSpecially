var builder = DistributedApplication.CreateBuilder(args);

// Add the catalog API project by specifying the path directly
builder.AddProject("catalog-api", "../Services/Catalog/Interface/WebApi/WebApi.csproj");

builder.Build().Run();