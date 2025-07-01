using CraftedSpecially.Catalog.Application.Interfaces;
using CraftedSpecially.Catalog.Domain.Aggregates.ProductAggregate;
using System.Diagnostics.Metrics;

namespace CraftedSpecially.Catalog.Application.Services;

public class ProductService : IProductService
{
    private readonly IProductRepository _productRepository;
    private static readonly Meter _meter = new("CraftedSpecially.Catalog");
    private static readonly Counter<int> _productLookupCounter = _meter.CreateCounter<int>("product_lookup_total", "count", "Total number of product lookups");
    private static readonly Histogram<double> _productLookupDuration = _meter.CreateHistogram<double>("product_lookup_duration_seconds", "seconds", "Duration of product lookup operations");

    public ProductService(IProductRepository productRepository)
    {
        _productRepository = productRepository;
    }

    public async ValueTask<bool> IsExistingProductAsync(string ProductName)
    {
        var stopwatch = System.Diagnostics.Stopwatch.StartNew();
        
        try
        {
            _productLookupCounter.Add(1, new KeyValuePair<string, object?>("operation", "product_exists_check"));
            
            var result = await _productRepository.GetProductByName(ProductName) != null;
            
            stopwatch.Stop();
            _productLookupDuration.Record(stopwatch.Elapsed.TotalSeconds, 
                new KeyValuePair<string, object?>("operation", "product_exists_check"),
                new KeyValuePair<string, object?>("found", result.ToString().ToLower()));
                
            return result;
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _productLookupDuration.Record(stopwatch.Elapsed.TotalSeconds, 
                new KeyValuePair<string, object?>("operation", "product_exists_check"),
                new KeyValuePair<string, object?>("status", "error"),
                new KeyValuePair<string, object?>("error_type", ex.GetType().Name));
                
            throw;
        }
    }
}
