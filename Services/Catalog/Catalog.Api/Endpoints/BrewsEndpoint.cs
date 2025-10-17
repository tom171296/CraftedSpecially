using System.Diagnostics;
using System.Diagnostics.Metrics;

namespace Catalog.Api.Endpoints;

/// <summary>
/// Minimal API endpoint mappings for brews.
/// Provides a shell GET endpoint that returns an empty list until implemented.
/// </summary>
public static class BrewsEndpoints
{
    // Meter for custom metrics
    private static readonly Meter Meter = new(MeterName, version: "1.0.0");
    private const string MeterName = "Catalog.Api.Brews";
    private static readonly Counter<int> BrewListRequestsCounter = Meter.CreateCounter<int>("brews.list.requests", description: "Number of requests to list brews.");
    private static readonly Histogram<double> BrewListLatency = Meter.CreateHistogram<double>("brews.list.duration.ms", unit: "ms", description: "Duration of listing brews.");

    private static void AddEvent(string name, ActivityTagsCollection tags)
    {
        Activity.Current?.AddEvent(new ActivityEvent(name, tags: tags));
    }

	/// <summary>
	/// Maps brews related endpoints.
	/// </summary>
	public static IEndpointRouteBuilder MapBrewsEndpoints(this IEndpointRouteBuilder endpoints)
	{
        endpoints.MapGet("/brews", HandleListBrews);
        endpoints.MapGet("/brews/favourites", HandleGetFavouriteBrews);
        endpoints.MapPost("/brews/{id:guid}/favorite", HandleNewFavouriteBrew);
		return endpoints;
	}

    /// <summary>
    /// Placeholder handler for listing brews.
    /// TODO: Replace with real implementation (e.g., inject application layer, query database, etc.).
    /// </summary>
    private static IResult HandleListBrews()
    {
        var activity = Activity.Current; // existing request span
        var start = Stopwatch.GetTimestamp();
        BrewListRequestsCounter.Add(1);

        try
        {
            var brews = Array.Empty<object>();

            AddEvent("brews.list.completed", new ActivityTagsCollection
            {
                ["brew.count"] = brews.Length,
                ["result.status"] = "ok"
            });

            activity?.SetTag("brew.count", brews.Length); // optional span tag
            return Results.Ok(brews);
        }
        catch (Exception ex)
        {
            activity?.SetStatus(ActivityStatusCode.Error, ex.Message);
            AddEvent("brews.list.error", new ActivityTagsCollection
            {
                ["exception.type"] = ex.GetType().FullName ?? "Unknown",
                ["exception.message"] = ex.Message
            });
            return Results.Problem(title: "Failed to list brews", detail: ex.Message);
        }
        finally
        {
            var durationMs = (Stopwatch.GetTimestamp() - start) * 1000.0 / Stopwatch.Frequency;
            BrewListLatency.Record(durationMs);
            activity?.SetTag("brews.list.duration.ms", durationMs); // keep if useful for tracing filters
        }
    }

    private static IResult HandleGetFavouriteBrews()
    {
        var favourites = Array.Empty<object>();
        AddEvent("brews.favourites.completed", new ActivityTagsCollection
        {
            ["favourite.count"] = favourites.Length
        });
        Activity.Current?.SetTag("favourite.count", favourites.Length);
        return Results.Ok(favourites);
    }

    private static IResult HandleNewFavouriteBrew()
    {
        var activity = Activity.Current;
        var id = Guid.NewGuid();
        AddEvent("brews.favourite.created", new ActivityTagsCollection
        {
            ["favourite.id"] = id.ToString()
        });
        activity?.SetStatus(ActivityStatusCode.Ok);
        return Results.Created($"/brews/{id}/favorite", null);
    }
}
