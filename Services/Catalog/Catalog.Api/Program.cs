using Catalog.Api.Services.Brews;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddScoped<IBrewOrderService, BrewOrderService>();
builder.Services.AddSingleton<BrewOrderInstrumentation>();
// builder.Services.AddEndpointsApiExplorer();
// builder.Services.AddSwaggerGen();

builder.AddServiceDefaults();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    // if desired enable swagger later
    // app.UseSwagger();
    // app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapControllers();

app.Run();
