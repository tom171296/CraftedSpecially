namespace CraftedSpecially.catalog.api;

public class Startup
{
    public Startup(IConfiguration configuration)
    {
        Configuration = configuration;
    }
 
    public IConfiguration Configuration { get; }
 
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddControllers();
    }
 
    public void Configure(IApplicationBuilder app)
    {
        app.UseHttpsRedirection();
        app.UseRouting();
 
        app.UseEndpoints(endpoints =>
        {
            endpoints.MapControllers();
        });
    }
}