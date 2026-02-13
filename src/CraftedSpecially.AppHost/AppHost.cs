var builder = DistributedApplication.CreateBuilder(args);

builder.AddProject("CraftedSpecially", "../CraftedSpecially.Api/CraftedSpecially.Api.csproj");
    //.WithEnvironment("APPLICATIONINSIGHTS_CONNECTION_STRING", "TODO");
builder.Build().Run();
