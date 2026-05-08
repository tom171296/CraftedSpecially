using System.Diagnostics;
using System.Diagnostics.Metrics;

namespace Catalog.Application;

public static class CatalogInstrumentation
{
    public const string SourceName = "Catalog";

    public static readonly ActivitySource ActivitySource = new(SourceName);
    public static readonly Meter Meter = new(SourceName);

    public static readonly Counter<long> BeersRequestCount =
        Meter.CreateCounter<long>("catalog.beers.request_count", description: "Number of times the beer list is requested");

    public static readonly Counter<long> BeersResultByAvailabilityCount =
        Meter.CreateCounter<long>("catalog.beers.result_by_availability_count", description: "Number of beer list requests, tagged by whether any beers were returned");
}
