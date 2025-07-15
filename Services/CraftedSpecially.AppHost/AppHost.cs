var builder = DistributedApplication.CreateBuilder(args);

var catalogService = builder.AddProject("Catalog", "../CraftedSpecially.Catalog/CraftedSpecially.Catalog.csproj");
builder.Build().Run();
