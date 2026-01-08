using System.Diagnostics.Metrics;

public class SearchMetrics
{
    public const string meterName = "CatalogAPI.SearchMetrics";
    
    private static Counter<int>? _listMetric;
    private static Counter<int>? _listResultMetric;

    public SearchMetrics(IMeterFactory meterFactory)
    {
        var meter = meterFactory.Create(new MeterOptions(meterName){ Version = "1.0.0" });
        _listMetric = meter.CreateCounter<int>("catalog_searched", description: "Counts the number of Catalog searches");
        _listResultMetric = meter.CreateCounter<int>("catalog_search_item_found", description: "Number of search requests that actually found an item");
    }

    public void RecordCatalogList()
    {
        _listMetric?.Add(1,
        [
            new KeyValuePair<string, object?>("test", "test")
        ]);
    }

    public void RecordCatalogListResult(int itemsFound)
    {
        
    }
}