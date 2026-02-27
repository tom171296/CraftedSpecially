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

    public static readonly Histogram<int> BeersReturnedCount =
        Meter.CreateHistogram<int>("catalog.beers.returned_count", description: "Distribution of how many beers are returned per request");
}
